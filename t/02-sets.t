use v6;

BEGIN { @*INC.push('t/') };
use Redis;
use Test;
use Test::SpawnRedisServer;

my $r = Redis.new(decode_response => True);
$r.connect;
$r.flushall;

plan 15;

is_deeply $r.sadd("set1", 1, 2, 3, 4), 4;
is_deeply $r.scard("set1"), 4;
$r.sadd("set2", 3, 4);
is_deeply $r.sdiff("set1", "set2"), ["1", "2"];
is_deeply $r.sdiffstore("set_diff", "set1", "set2"), 2;
is_deeply $r.smembers("set_diff"), ["1", "2"];
is_deeply $r.sinter("set1", "set2"), ["3", "4"];
is_deeply $r.sinterstore("set_inter", "set2"), 2;
is_deeply $r.sismember("set_inter", 3), True;

# smove
is_deeply $r.smove("set_inter", "set_diff", 3), True;

# spop
ok $r.spop("set_diff") eq any("1", "2", "3");
is_deeply $r.scard("set_diff"), 2;

# srandmember
ok $r.srandmember("set_diff") eq any("1", "2", "3");

# srem
is_deeply $r.srem("set_inter", "3", "4"), 0;

# sunion & sunionstore
is_deeply $r.sunion("set1", "set2"), ["1", "2", "3", "4"];
is_deeply $r.sunionstore("set_union", "set1", "set2"), 4;

# vim: ft=perl6
