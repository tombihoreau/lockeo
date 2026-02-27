import { IsInt, Min } from 'class-validator';

export class EnsureConversationDto {
  @IsInt()
  @Min(1)
  otherUserId: number;
}
