import { IsIn, IsString } from 'class-validator';

export class UpdateReservationStatusDto {
  @IsString()
  @IsIn(['accepted', 'refused'])
  status: 'accepted' | 'refused';
}
