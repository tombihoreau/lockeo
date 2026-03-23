import {
  MigrationInterface,
  QueryRunner,
  TableColumn,
  TableForeignKey,
  TableIndex,
} from 'typeorm';

export class AddConversationReservationRelation20260323153000
  implements MigrationInterface
{
  name = 'AddConversationReservationRelation20260323153000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const table = await queryRunner.getTable('conversations');
    if (!table) {
      return;
    }

    const hasColumn = table.findColumnByName('reservationReservationId');
    if (!hasColumn) {
      await queryRunner.addColumn(
        'conversations',
        new TableColumn({
          name: 'reservationReservationId',
          type: 'int',
          isNullable: true,
        }),
      );
    }

    const refreshedTable = await queryRunner.getTable('conversations');
    if (!refreshedTable) {
      return;
    }

    const hasForeignKey = refreshedTable.foreignKeys.some(
      (foreignKey) =>
        foreignKey.columnNames.length === 1 &&
        foreignKey.columnNames[0] === 'reservationReservationId',
    );

    if (!hasForeignKey) {
      await queryRunner.createForeignKey(
        'conversations',
        new TableForeignKey({
          columnNames: ['reservationReservationId'],
          referencedTableName: 'reservations',
          referencedColumnNames: ['reservation_id'],
          onDelete: 'SET NULL',
        }),
      );
    }

    const hasIndex = refreshedTable.indices.some(
      (index) =>
        index.columnNames.length === 1 &&
        index.columnNames[0] === 'reservationReservationId',
    );

    if (!hasIndex) {
      await queryRunner.createIndex(
        'conversations',
        new TableIndex({
          name: 'IDX_conversations_reservationReservationId',
          columnNames: ['reservationReservationId'],
        }),
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const table = await queryRunner.getTable('conversations');
    if (!table) {
      return;
    }

    const index = table.indices.find(
      (item) => item.name === 'IDX_conversations_reservationReservationId',
    );
    if (index) {
      await queryRunner.dropIndex('conversations', index);
    }

    const foreignKey = table.foreignKeys.find(
      (item) =>
        item.columnNames.length === 1 &&
        item.columnNames[0] === 'reservationReservationId',
    );
    if (foreignKey) {
      await queryRunner.dropForeignKey('conversations', foreignKey);
    }

    const column = table.findColumnByName('reservationReservationId');
    if (column) {
      await queryRunner.dropColumn('conversations', column);
    }
  }
}
