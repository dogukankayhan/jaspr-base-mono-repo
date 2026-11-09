enum InjectionTime { atDocumentStart, atDocumentEnd }

class JsInjection {
  final String code;
  final InjectionTime injectionTime;

  const JsInjection(
    this.code, {
    this.injectionTime = InjectionTime.atDocumentEnd,
  });
}
