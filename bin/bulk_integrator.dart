/*
  Copyright 2020-2022 i3-MARKET Consortium:

  ATHENS UNIVERSITY OF ECONOMICS AND BUSINESS - RESEARCH CENTER
  ATOS SPAIN SA
  EUROPEAN DIGITAL SME ALLIANCE
  GFT ITALIA SRL
  GUARDTIME OU
  HOP UBIQUITOUS SL
  IBM RESEARCH GMBH
  IDEMIA FRANCE
  SIEMENS AKTIENGESELLSCHAFT
  SIEMENS SRL
  TELESTO TECHNOLOGIES PLIROFORIKIS KAI EPIKOINONION EPE
  UNIVERSITAT POLITECNICA DE CATALUNYA
  UNPARALLEL INNOVATION LDA

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
import 'dart:io';
import './integrate.dart';
import 'package:path/path.dart';


void main(List<String> args) async {
  if (args.length != 2) {
    printHelp();
  } else {
    await runBulkIntegration(args[0], args[1]);
  }
}

Future<void> runBulkIntegration(String backplanePath, String specsPath) async {
  final specsDir = Directory(specsPath);
  final specs = specsDir
      .listSync(followLinks: false)
      .whereType<File>()
      .where((element) => extension(element.path) == '.json')
      .toList();
  print('Integrating following services:');
  print('\t${specs.map((file) => basenameWithoutExtension(file.path)).join('\n\t')}');
  print('==========================================================================================');
  for (final spec in specs) {
    final serviceName = basenameWithoutExtension(spec.path);
    print('Integrating $serviceName');

    Directory('$backplanePath/integrated_services/sources').createSync(recursive: true);
    final fileName = '$backplanePath/integrated_services/$serviceName.json';
    final sourceName = '$backplanePath/integrated_services/sources/$serviceName.json';

    final specFile = spec.copySync(fileName)..copySync(sourceName);

    modifySpec(specFile);
    integrateService(backplanePath, serviceName, specFile);

    print('==========================================================================================');
  }
}

void printHelp() {
  print('Usage:\n'
      '\tdart bulk_integrator.dart <Backplane path> <Specs path>\n'
      '\tbulk_integrator <Backplane path> <Specs path>\n');
}
