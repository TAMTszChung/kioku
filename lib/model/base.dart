/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:kioku/service/database.dart';

abstract class BaseModel {
  final DBCols cols;
  BaseModel({required this.cols});
}
