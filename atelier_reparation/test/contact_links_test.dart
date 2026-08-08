import 'package:atelier_reparation/shared/widgets/apple/contact_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('whatsappUri keeps digits only', () {
    expect(whatsappUri('+33 6 12 34 56 78').toString(), 'https://wa.me/33612345678');
  });

  group('telegramUri', () {
    test('strips a leading @ handle', () {
      expect(telegramUri('@dubois_info').toString(), 'https://t.me/dubois_info');
    });
    test('accepts a bare handle', () {
      expect(telegramUri('dubois_info').toString(), 'https://t.me/dubois_info');
    });
    test('routes a numeric value to t.me/+digits', () {
      expect(telegramUri('33612345678').toString(), 'https://t.me/+33612345678');
    });
  });

  group('websiteUri', () {
    test('adds https:// when scheme is missing', () {
      expect(websiteUri('dubois-info.fr').toString(), 'https://dubois-info.fr');
    });
    test('keeps an existing scheme', () {
      expect(websiteUri('http://x.com').toString(), 'http://x.com');
    });
  });

  test('instagramUri builds a profile URL from @handle', () {
    expect(instagramUri('@dubois.informatique').toString(),
        'https://instagram.com/dubois.informatique');
  });

  group('social profiles', () {
    test('facebookUri strips @ and builds facebook.com/<handle>', () {
      expect(facebookUri('@dubois').toString(), 'https://facebook.com/dubois');
    });
    test('linkedinUri routes to /in/<handle>', () {
      expect(linkedinUri('emma-dubois').toString(),
          'https://linkedin.com/in/emma-dubois');
    });
    test('xUri strips @ and builds x.com/<handle>', () {
      expect(xUri('@dubois').toString(), 'https://x.com/dubois');
    });
    test('a full URL is kept as-is', () {
      expect(facebookUri('https://fb.com/pg/x').toString(), 'https://fb.com/pg/x');
    });
    test('snapchatUri builds add link', () {
      expect(snapchatUri('@ghost').toString(), 'https://snapchat.com/add/ghost');
    });
    test('tiktokUri keeps the @ in the path', () {
      expect(tiktokUri('dubois').toString(), 'https://tiktok.com/@dubois');
      expect(tiktokUri('@dubois').toString(), 'https://tiktok.com/@dubois');
    });
    test('signalUri routes to signal.me with digits', () {
      final s = signalUri('+33 6 12 34 56 78').toString();
      expect(s, startsWith('https://signal.me/'));
      expect(s, contains('33612345678'));
    });
    test('messengerUri builds m.me/<handle>', () {
      expect(messengerUri('@dubois').toString(), 'https://m.me/dubois');
    });
    test('lineUri routes to line.me/ti/p/~<id>', () {
      expect(lineUri('~dubois').toString(), 'https://line.me/ti/p/~dubois');
    });
    test('youtubeUri keeps the @ in the path', () {
      expect(youtubeUri('dubois').toString(), 'https://youtube.com/@dubois');
    });
    test('viberUri targets the viber scheme with the number', () {
      final v = viberUri('+33612345678').toString();
      expect(v, startsWith('viber://chat?number='));
      expect(v, contains('33612345678'));
    });
    test('teamsUri opens a chat with the email', () {
      final t = teamsUri('emma@dubois-info.fr').toString();
      expect(t, startsWith('https://teams.microsoft.com/l/chat/0/0?users='));
      expect(t, contains('emma'));
    });
  });
}
