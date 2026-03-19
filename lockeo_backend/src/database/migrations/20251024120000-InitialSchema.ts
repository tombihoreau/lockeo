import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableForeignKey,
  TableUnique,
  TableIndex,
} from 'typeorm';

export class InitialSchema20251024120000 implements MigrationInterface {
  name = 'InitialSchema20251024120000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // users
    await queryRunner.createTable(
      new Table({
        name: 'users',
        columns: [
          {
            name: 'user_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'email', type: 'varchar', length: '100', isNullable: false },
          { name: 'login', type: 'varchar', length: '100', isNullable: false },
          {
            name: 'password_hash',
            type: 'varchar',
            length: '255',
            isNullable: false,
          },
          {
            name: 'first_name',
            type: 'varchar',
            length: '50',
            isNullable: true,
          },
          {
            name: 'last_name',
            type: 'varchar',
            length: '50',
            isNullable: true,
          },
          {
            name: 'phone_number',
            type: 'varchar',
            length: '20',
            isNullable: true,
          },
          { name: 'longitude', type: 'float', isNullable: true },
          { name: 'latitude', type: 'float', isNullable: true },
          { name: 'city', type: 'varchar', length: '50', isNullable: true },
          {
            name: 'postal_code',
            type: 'varchar',
            length: '10',
            isNullable: true,
          },
          { name: 'is_verified', type: 'tinyint', default: 0 },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updated_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
        ],
        uniques: [
          new TableUnique({ name: 'UQ_users_email', columnNames: ['email'] }),
          new TableUnique({ name: 'UQ_users_login', columnNames: ['login'] }),
        ],
      }),
      true,
    );

    // categories
    await queryRunner.createTable(
      new Table({
        name: 'categories',
        columns: [
          {
            name: 'category_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'label', type: 'varchar', length: '50', isNullable: false },
        ],
        uniques: [
          new TableUnique({
            name: 'UQ_categories_label',
            columnNames: ['label'],
          }),
        ],
      }),
      true,
    );

    // notification_templates
    await queryRunner.createTable(
      new Table({
        name: 'notification_templates',
        columns: [
          {
            name: 'template_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'code', type: 'varchar', length: '50', isNullable: false },
          { name: 'title', type: 'varchar', length: '250', isNullable: false },
          { name: 'content', type: 'text', isNullable: false },
        ],
        uniques: [
          new TableUnique({
            name: 'UQ_notification_templates_code',
            columnNames: ['code'],
          }),
        ],
      }),
      true,
    );

    // message_templates
    await queryRunner.createTable(
      new Table({
        name: 'message_templates',
        columns: [
          {
            name: 'message_template_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'code', type: 'varchar', length: '50', isNullable: false },
          { name: 'title', type: 'varchar', length: '250', isNullable: false },
          { name: 'content', type: 'text', isNullable: false },
        ],
        uniques: [
          new TableUnique({
            name: 'UQ_message_templates_code',
            columnNames: ['code'],
          }),
        ],
      }),
      true,
    );

    // products
    await queryRunner.createTable(
      new Table({
        name: 'products',
        columns: [
          {
            name: 'product_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'name', type: 'varchar', length: '50', isNullable: false },
          { name: 'description', type: 'text', isNullable: true },
          {
            name: 'price',
            type: 'decimal',
            precision: 8,
            scale: 2,
            isNullable: false,
          },
          {
            name: 'price_estimate',
            type: 'decimal',
            precision: 8,
            scale: 2,
            isNullable: true,
          },
          { name: 'state', type: 'varchar', length: '50', isNullable: false },
          { name: 'longitude', type: 'float', isNullable: true },
          { name: 'latitude', type: 'float', isNullable: true },
          { name: 'city', type: 'varchar', length: '50', isNullable: false },
          {
            name: 'postal_code',
            type: 'varchar',
            length: '10',
            isNullable: false,
          },
          { name: 'is_available', type: 'tinyint', default: 1 },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updated_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'ownerUserId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['ownerUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // products_has_categories
    await queryRunner.createTable(
      new Table({
        name: 'products_has_categories',
        columns: [
          {
            name: 'product_has_category_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'productProductId', type: 'int' },
          { name: 'categoryCategoryId', type: 'int' },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['productProductId'],
            referencedTableName: 'products',
            referencedColumnNames: ['product_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['categoryCategoryId'],
            referencedTableName: 'categories',
            referencedColumnNames: ['category_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // product_unavailabilities
    await queryRunner.createTable(
      new Table({
        name: 'product_unavailabilities',
        columns: [
          {
            name: 'unavailability_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'start_date_time', type: 'datetime' },
          { name: 'end_date_time', type: 'datetime' },
          { name: 'productProductId', type: 'int' },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['productProductId'],
            referencedTableName: 'products',
            referencedColumnNames: ['product_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // offers
    await queryRunner.createTable(
      new Table({
        name: 'offers',
        columns: [
          {
            name: 'offer_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'status', type: 'varchar', length: '50' },
          { name: 'amount', type: 'decimal', precision: 8, scale: 2 },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'ownerUserId', type: 'int', isNullable: true },
          { name: 'productProductId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['ownerUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['productProductId'],
            referencedTableName: 'products',
            referencedColumnNames: ['product_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // reservations
    await queryRunner.createTable(
      new Table({
        name: 'reservations',
        columns: [
          {
            name: 'reservation_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'start_date', type: 'datetime' },
          { name: 'end_date', type: 'datetime' },
          { name: 'status', type: 'varchar', length: '50' },
          { name: 'final_price', type: 'decimal', precision: 8, scale: 2 },
          {
            name: 'verification_code',
            type: 'varchar',
            length: '50',
            isNullable: true,
          },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updated_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'offerOfferId', type: 'int', isNullable: true },
          { name: 'renterUserId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['offerOfferId'],
            referencedTableName: 'offers',
            referencedColumnNames: ['offer_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['renterUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // reviews (1-1 with reservation)
    await queryRunner.createTable(
      new Table({
        name: 'reviews',
        columns: [
          {
            name: 'review_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'rating', type: 'int' },
          { name: 'comment', type: 'text', isNullable: true },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'userUserId', type: 'int', isNullable: true },
          { name: 'reservationReservationId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['userUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['reservationReservationId'],
            referencedTableName: 'reservations',
            referencedColumnNames: ['reservation_id'],
            onDelete: 'CASCADE',
          }),
        ],
        uniques: [
          new TableUnique({
            name: 'UQ_reviews_reservation',
            columnNames: ['reservationReservationId'],
          }),
        ],
      }),
      true,
    );

    // images
    await queryRunner.createTable(
      new Table({
        name: 'images',
        columns: [
          {
            name: 'image_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'uri', type: 'varchar', length: '250' },
          { name: 'position_image', type: 'int', default: 0 },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'productProductId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['productProductId'],
            referencedTableName: 'products',
            referencedColumnNames: ['product_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // conversations
    await queryRunner.createTable(
      new Table({
        name: 'conversations',
        columns: [
          {
            name: 'conversation_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'renterUserId', type: 'int', isNullable: true },
          { name: 'ownerUserId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['renterUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['ownerUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // messages
    await queryRunner.createTable(
      new Table({
        name: 'messages',
        columns: [
          {
            name: 'message_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'content', type: 'varchar', length: '500' },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'conversationConversationId', type: 'int', isNullable: true },
          { name: 'senderUserId', type: 'int', isNullable: true },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['conversationConversationId'],
            referencedTableName: 'conversations',
            referencedColumnNames: ['conversation_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['senderUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // favorites
    await queryRunner.createTable(
      new Table({
        name: 'favorites',
        columns: [
          {
            name: 'favorite_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'userUserId', type: 'int' },
          { name: 'productProductId', type: 'int' },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['userUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
          new TableForeignKey({
            columnNames: ['productProductId'],
            referencedTableName: 'products',
            referencedColumnNames: ['product_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // user_notifications
    await queryRunner.createTable(
      new Table({
        name: 'user_notifications',
        columns: [
          {
            name: 'user_notification_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'status', type: 'varchar', length: '50' },
          {
            name: 'created_at',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          { name: 'templateTemplateId', type: 'int', isNullable: true },
          { name: 'destinationUserUserId', type: 'int' },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['templateTemplateId'],
            referencedTableName: 'notification_templates',
            referencedColumnNames: ['template_id'],
            onDelete: 'SET NULL',
          }),
          new TableForeignKey({
            columnNames: ['destinationUserUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // notification_preferences
    await queryRunner.createTable(
      new Table({
        name: 'notification_preferences',
        columns: [
          {
            name: 'notification_preference_id',
            type: 'int',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          { name: 'code', type: 'varchar', length: '50' },
          { name: 'allowed', type: 'tinyint', default: 1 },
          { name: 'userUserId', type: 'int' },
        ],
        foreignKeys: [
          new TableForeignKey({
            columnNames: ['userUserId'],
            referencedTableName: 'users',
            referencedColumnNames: ['user_id'],
            onDelete: 'CASCADE',
          }),
        ],
      }),
      true,
    );

    // indexes (optional minimal)
    await queryRunner.createIndex(
      'users',
      new TableIndex({ name: 'IDX_users_email', columnNames: ['email'] }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('notification_preferences', true);
    await queryRunner.dropTable('user_notifications', true);
    await queryRunner.dropTable('favorites', true);
    await queryRunner.dropTable('messages', true);
    await queryRunner.dropTable('conversations', true);
    await queryRunner.dropTable('images', true);
    await queryRunner.dropTable('reviews', true);
    await queryRunner.dropTable('reservations', true);
    await queryRunner.dropTable('offers', true);
    await queryRunner.dropTable('product_unavailabilities', true);
    await queryRunner.dropTable('products_has_categories', true);
    await queryRunner.dropTable('products', true);
    await queryRunner.dropTable('message_templates', true);
    await queryRunner.dropTable('notification_templates', true);
    await queryRunner.dropTable('categories', true);
    await queryRunner.dropIndex('users', 'IDX_users_email');
    await queryRunner.dropTable('users', true);
  }
}
