import { IsString } from 'class-validator';

export class CreateReservationDto {
  @IsString()
  startDate: string;

  @IsString()
  endDate: string;
}
