var scalabilityModeRegex = RegExp('^[LS]([1-9]\\d{0,1})T([1-9]\\d{0,1})');

class ScalabilityMode {
  int spatialLayers;
  int temporalLayers;
  ScalabilityMode(
    this.spatialLayers,
    this.temporalLayers,
  );
}

ScalabilityMode parse({String? scalabilityMode = ''}) {
  var match = scalabilityModeRegex.allMatches(scalabilityMode);

  if (match != null && match.length != 0) {
    return ScalabilityMode(
      int.parse(match.elementAt(1).group(0)!),
      int.parse(match.elementAt(2).group(0)!),
    );
    // 	spatialLayers  : Number(match[1]),
    // 	temporalLayers : Number(match[2])
    // };
  } else {
    return ScalabilityMode(
      1,
      1,
    );
  }
}
