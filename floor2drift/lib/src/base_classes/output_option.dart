import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/floor2drift.dart';

/// {@template OutputOptionBase}
/// All options for the [Floor2DriftGenerator] for where and how the files should be output to
/// {@endtemplate}
abstract class OutputOptionBase {
  /// dryRun the generator
  ///
  /// will not output any files but write the location of files that would be written to the console
  final bool dryRun;

  /// Suffix that will be added to the name of Floor files to create the drift file
  ///
  /// If the suffix is empty the existing floor files will be overwritten
  final String fileSuffix;

  /// {@macro OutputOptionBase}
  const OutputOptionBase({required this.dryRun, required this.fileSuffix});

  /// converts the given [filePath] to the corresponding output path
  String getNewPath(String filePath);

  /// rewrites the given name corresponding to the output options
  ///
  /// [willChange] should be true if the class that is being imported will be converted to a drift class
  /// [currentImport] the import directive that should be rewritten
  /// outputs the package or relative import directive as a string
  String rewriteImport(bool willChange, DirectiveUriWithLibrary currentImport);

  /// rewrites the given name corresponding to the output options
  ///
  /// [willChange] should be true if the class that is being imported will be converted to a drift class
  /// [currentImport] the import directive that should be rewritten
  /// outputs the package or relative import directive as a string
  String rewriteImportString(bool willImportedChange, String path);

  /// rewrites the given name corresponding to the output options
  String rewriteExistingImport(String importDirective);

  /// returns the new fileName of the give [fileName]
  String getFileName(String fileName);

  /// writes [content] to the given [newFile]
  bool writeFile(File newFile, String content);
}

/// {@macro OutputOptionBase}
class OutputOptions extends OutputOptionBase {
  /// {@macro OutputOptionBase}
  const OutputOptions({required super.fileSuffix, required super.dryRun});

  @override
  bool writeFile(File newFile, String content) {
    IOSink? sink;
    try {
      if (dryRun) {
        print("Writing ${newFile.path}");
      } else {
        newFile.createSync(recursive: true);
        sink = newFile.openWrite();
        sink.write(content);
      }
      return true;
    } on Exception {
      print("Exception while writing ReplaceOutput output");
      return false;
    } finally {
      // finally will run even with the return
      sink?.close();
    }
  }

  @override
  String getNewPath(String filePath) {
    final newPath = _addSuffixToString(filePath);
    return newPath;
  }

  @override
  String rewriteImport(bool willChange, DirectiveUriWithLibrary currentImport) {
    return rewriteImportString(willChange, currentImport.relativeUriString);
  }

  @override
  String rewriteExistingImport(String importDirective) {
    return _addSuffixToString(importDirective);
  }

  @override
  String rewriteImportString(bool willImportedChange, String path) {
    if (willImportedChange) {
      return "import '${_addSuffixToString(path)}';";
    } else {
      return "import '$path';";
    }
  }

  @override
  String getFileName(String fileName) {
    return _addSuffixToString(fileName);
  }

  String _addSuffixToString(String filename) {
    return filename.splitMapJoin(".dart", onMatch: (m) => "$fileSuffix${m[0]}", onNonMatch: (n) => n);
  }
}

// TODO more complicated than anticipated. Maybe try again in the future.
// TODO The file itself needs to be moved.
// TODO The imports of the file needs to be rewritten if the file will change to
// TODO Other files could be in a completely differen libary.
// /// Output every file in a different Directory with the same directory structure
// class OutputOptionDirectory extends OutputOption {
//   final Directory directory;
//
//   const OutputOptionDirectory(this.directory, super.dryRun, super.root);
//
//   /// TODO
//   String? _calulateRootBetweenDirs(String newFilePath) {
//     final directoryPath = directory.absolute.uri.pathSegments;
//
//     // TODO clean up relative directory path
//     // TODO remove segments with .
//     // TODO remove segments and segments before with ..
//
//     var newRoot = Platform.pathSeparator;
//
//     for (final path in directoryPath) {
//       newRoot += path + Platform.pathSeparator;
//
//       if (newFilePath.startsWith(newRoot) == false) {
//         // TODO doesnt work with relative paths
//         // TODO               /projects/project-flutter/lib/main/db/drift/drift_entity.dart
//         // TODO newDirectory /projects/project-flutter/lib/test/../main/db
//         // TODO expected    /projects/project-flutter/lib/main/db
//         // TODO current     /projects/project-flutter/lib/
//
//         // remove last Path Separator
//         newRoot = newRoot.substring(0, newRoot.length - 1);
//         // remove last wrong directory
//         newRoot =
//             newRoot.substring(0, newRoot.lastIndexOf(Platform.pathSeparator));
//         newRoot += Platform.pathSeparator;
//         break;
//       }
//     }
//     // TODO old directory /projects/project-flutter/lib/main/db/floor/floor_entity.dart
//     // TODO new directory /projects/project-flutter/lib/main/drift/db/
//     // TODO newRoot         /projects/project-flutter/lib/main/
//     // TODO expected      /projects/project-flutter/lib/main/drift/db/db/floor/floor_entity
//     // TODO root          /projects/project-flutter/lib/
//
//     // TODO sanity check with super.root path
//
//     if (newRoot.contains(root.absolute.path) == false) {
//       // TODO something went horribly wrong
//       return null;
//     }
//
//     return newRoot;
//   }
//
//   // TODO how does that work with entities in a different libary as daos as database.
//   @override
//   String getNewPath(String filePath) {
//     var newRoot = _calulateRootBetweenDirs(filePath);
//
//     if (newRoot == null) {
//       return "";
//     }
//
//     final beginString = filePath.indexOf(newRoot);
//
//     // -1 to remove the PathSeparator
//     var dirStructure = filePath.substring(beginString + newRoot.length);
//
//     final newPath = directory.absolute.uri.path + dirStructure;
//
//     return newPath;
//   }
//
//   // TODO has to rewrite every non package (relative) import
//   // TODO clean up/rewrite .
//   @override
//   String rewriteImport(
//     (bool willChange, DirectiveUriWithLibrary currentImport) import,
//     (bool willChange, LibraryReader currentLibrary) currentFile,
//   ) {
//     final uri = import.$2.relativeUri;
//     final importScheme = uri.hasScheme ? uri.scheme : "";
//
//     if (import.$1 == false && importScheme.isNotEmpty) {
//       return "import '${import.$2.relativeUriString}';";
//     }
//
//     // source uri should be always the package import
//     final absoluteImportUri = import.$2.source.uri;
//
//     var withoutPackage =
//         absoluteImportUri.pathSegments.sublist(1).join(Platform.pathSeparator);
//
//     var currentLocationUri = Uri.file(root.absolute.uri.path + withoutPackage);
//
//     final dirStructure = _calulateNewDir(currentLocationUri);
//
//     if (dirStructure == null) {
//       throw InvalidGenerationSource("dirStructure is Empty");
//     }
//
//     final absoluteDirectory = directory.absolute.uri;
//
//     if (importScheme.isNotEmpty) {
//       var index = absoluteDirectory.path.indexOf(root.absolute.uri.path);
//       var newString = Platform.pathSeparator +
//           absoluteDirectory.path.substring(
//             index + root.absolute.uri.path.length,
//           );
//
//       var packageName = absoluteImportUri.pathSegments[0];
//       return "import '$importScheme:$packageName$newString$dirStructure';";
//     } else {
//       final newLocationUri = Uri.file(absoluteDirectory.path + dirStructure);
//
//       String from;
//       String to;
//
//       if (currentFile.$1) {
//         if (import.$1 == false) {
//           to = currentLocationUri.path;
//         } else {
//           to = newLocationUri.path;
//         }
//
//         var withoutPackage2 = currentFile
//             .$2.element.librarySource.uri.pathSegments
//             .sublist(1)
//             .join(Platform.pathSeparator);
//
//         final currentLibraryFileUri =
//             Uri.file(root.absolute.uri.path + withoutPackage2);
//
//         final newDirStructure = _calulateNewDir(currentLibraryFileUri);
//
//         if (newDirStructure == null) {
//           throw InvalidGenerationSource("newDirStructure is null");
//         }
//
//         var index2 = absoluteDirectory.path.indexOf(root.absolute.uri.path);
//
//         var newString2 = absoluteDirectory.path.substring(
//           index2 + root.absolute.uri.path.length,
//         );
//
//         var newFileLocationfile =
//             Uri.file(root.absolute.uri.path + newString2 + newDirStructure);
//         from = Platform.pathSeparator +
//             p.joinAll(
//               newFileLocationfile.pathSegments
//                   .sublist(0, newFileLocationfile.pathSegments.length - 1),
//             );
//       } else {
//         to = newLocationUri.path;
//         from = root.absolute.path +
//             p.joinAll(
//               currentFile.$2.element.source.uri.pathSegments.sublist(
//                   0, currentFile.$2.element.source.uri.pathSegments.length - 1),
//             );
//       }
//
//       final result = p.relative(
//         to,
//         from: from,
//       );
//
//       return "import '$result';";
//     }
//   }
//
//   String? _calulateNewDir(Uri currentLocationUri) {
//     final tempRoot = _calulateRootBetweenDirs(currentLocationUri.path);
//
//     if (tempRoot == null) {
//       return null;
//     }
//
//     // TODO Test with non zero beginString
//     final beginString = currentLocationUri.path.indexOf(tempRoot);
//
//     var dirStructure = currentLocationUri.path.substring(
//       beginString + tempRoot.length,
//     );
//
//     return dirStructure;
//   }
//
//   @override
//   String getFileName(String fileName) {
//     return fileName;
//   }
// }
//
// /// Output every file in a differen Directory. All files are being put in the same directorry
// /// TODO cant work with non package imports
// class OutputOptionDirectory2 extends OutputOption {
//   final Directory directory;
//
//   const OutputOptionDirectory2(this.directory, super.dryRun, super.root);
//
//   @override
//   String getNewPath(String filePath) {
//     // TODO: implement writeOutput
//     throw UnimplementedError();
//   }
//
//   @override
//   String rewriteImport(
//     (bool willChange, DirectiveUriWithLibrary currentImport) import,
//     (bool willChange, LibraryReader currentLibrary) currentFile,
//   ) {
//     // TODO: implement rewriteImport
//     // TODO change directory to directory delete all subfolders?
//     throw UnimplementedError();
//   }
//
//   @override
//   String getFileName(String fileName) {
//     // TODO: implement getFileName
//     throw UnimplementedError();
//   }
// }
