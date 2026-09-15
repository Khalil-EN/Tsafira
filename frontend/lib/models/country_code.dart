class CountryCode {
  final String name;
  final String isoCode;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.isoCode,
    required this.dialCode,
    required this.flag,
  });
}

const List<CountryCode> countryCodes = [
  CountryCode(name: 'Morocco', isoCode: 'MA', dialCode: '+212', flag: '🇲🇦'),
  CountryCode(name: 'United States', isoCode: 'US', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(name: 'France', isoCode: 'FR', dialCode: '+33', flag: '🇫🇷'),
  CountryCode(name: 'United Kingdom', isoCode: 'GB', dialCode: '+44', flag: '🇬🇧'),
  CountryCode(name: 'Canada', isoCode: 'CA', dialCode: '+1', flag: '🇨🇦'),
  CountryCode(name: 'Spain', isoCode: 'ES', dialCode: '+34', flag: '🇪🇸'),
];