program ValBuiltinEdges;
{ Val follows Turbo/Free Pascal on every platform: Code is the 1-based position
  of the first bad character (one past the end when the text stops early) and
  the destination is left unchanged on error. Regression: on Linux, Val('', n,
  code) reported success with n = 0. }

var
  failures: Integer;

procedure CheckInt(const s: string; wantValue, wantCode: Integer);
var
  n, code: Integer;
begin
  n := 5;
  code := -1;
  Val(s, n, code);
  if (n <> wantValue) or (code <> wantCode) then
  begin
    Writeln('FAIL: Val(''', s, ''') n=', n, ' code=', code,
            ' want n=', wantValue, ' code=', wantCode);
    failures := failures + 1;
  end;
end;

procedure CheckReal(const s: string; wantValue: Real; wantCode: Integer);
var
  r: Real;
  code: Integer;
begin
  r := 5.0;
  code := -1;
  Val(s, r, code);
  if (abs(r - wantValue) > 1e-9) or (code <> wantCode) then
  begin
    Writeln('FAIL: Val(''', s, ''') r=', r:0:6, ' code=', code,
            ' want r=', wantValue:0:6, ' code=', wantCode);
    failures := failures + 1;
  end;
end;

begin
  failures := 0;
  CheckInt('', 5, 1);
  CheckInt('-', 5, 2);
  CheckInt('+', 5, 2);
  CheckInt('  ', 5, 3);
  CheckInt(' 42', 42, 0);
  CheckInt('42 ', 5, 3);
  CheckInt('-13', -13, 0);
  CheckInt('7x', 5, 2);
  CheckInt('--1', 5, 2);
  CheckInt('123456789012345678901234567890', 5, 20);
  CheckReal('', 5.0, 1);
  CheckReal('.', 5.0, 2);
  CheckReal(' 2.5', 2.5, 0);
  CheckReal('2.5 ', 5.0, 4);
  CheckReal('1e', 5.0, 3);
  CheckReal('-1.5e-2', -0.015, 0);
  CheckReal('1e-400', 0.0, 0);
  if failures = 0 then
    Writeln('PASS: val builtin edges');
end.
