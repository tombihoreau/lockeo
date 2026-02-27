import { IsBoolean, IsInt, Min } from 'class-validator';

export class TypingDto {
  @IsInt()
  @Min(1)
  conversationId: number;

  @IsBoolean()
  isTyping: boolean;
}
