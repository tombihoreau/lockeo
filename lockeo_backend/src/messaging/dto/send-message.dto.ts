import { IsInt, IsString, MaxLength, Min } from 'class-validator';

export class SendMessageDto {
  @IsInt()
  @Min(1)
  conversationId: number;

  @IsString()
  @MaxLength(500)
  text: string;
}
