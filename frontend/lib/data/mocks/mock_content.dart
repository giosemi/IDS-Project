import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/content_type.dart';

const mockContents = <ContentItem>[
  ContentItem(
    id: '1',
    title: 'Notte stellata',
    description: 'Paesaggio notturno con cielo vorticoso sopra un villaggio.',
    year: 1889,
    ownerId: 'user-1',
    type: ContentType.cv,
  ),
  ContentItem(
    id: '2',
    title: 'Sonata al chiaro di luna',
    description: 'Registrazione live al pianoforte.',
    year: 2024,
    ownerId: 'user-2',
    type: ContentType.audio,
    duration: '14:32',
  ),
  ContentItem(
    id: '3',
    title: 'Il bacio',
    description: 'Coppia abbracciata avvolta da motivi dorati decorativi.',
    year: 1908,
    ownerId: 'user-1',
    type: ContentType.cv,
  ),
  ContentItem(
    id: '4',
    title: 'Audizione Conservatorio',
    description: 'Video performance completa per commissione d\'esame.',
    year: 2025,
    ownerId: 'user-1',
    type: ContentType.video,
    duration: '8:45',
  ),
  ContentItem(
    id: '5',
    title: 'Preludio e fuga',
    description: 'Spartito manoscritto per ensemble d\'archi.',
    year: 2023,
    ownerId: 'user-1',
    type: ContentType.score,
  ),
  ContentItem(
    id: '6',
    title: 'CV artistico',
    description: 'Percorso formativo, masterclass e premi ottenuti.',
    year: 2025,
    ownerId: 'user-1',
    type: ContentType.cv,
  ),
];
