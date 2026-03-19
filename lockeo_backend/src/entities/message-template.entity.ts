import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('message_templates')
export class MessageTemplate {
  @PrimaryGeneratedColumn()
  message_template_id: number;

  @Column({ length: 50, unique: true })
  code: string;

  @Column({ length: 250 })
  title: string;

  @Column({ type: 'text' })
  content: string;
}
