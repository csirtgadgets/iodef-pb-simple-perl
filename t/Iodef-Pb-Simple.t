use Test::More;
BEGIN { use_ok('Iodef::Pb::Simple') };

use UUID::Tiny ':std';
use Iodef::Pb::Simple qw/uuid_ns uuid_random/;

ok(create_uuid_as_string(UUID_RANDOM));
ok(create_uuid_as_string(UUID_V3, UUID_NIL, 'everyone') eq '8c864306-d21a-37b1-8705-746a786719bf');
ok(create_uuid_as_string(UUID_V3, UUID_NIL, 'root') eq '1893558f-9371-3bcd-9369-aa4942339231');

ok(uuid_random() ne uuid_random());
ok(uuid_ns('everyone') eq '8c864306-d21a-37b1-8705-746a786719bf');
ok(uuid_ns('root') eq '1893558f-9371-3bcd-9369-aa4942339231');
ok(uuid_ns('p1.example.com') eq '13805ea4-fe04-3ac6-9339-40ad396b6d41');

done_testing();
