# shellcheck shell=bash
# Reusable E2E test harness for Mathify Lite.
# Source this from a Bash (Git Bash) shell, NOT PowerShell:  source helpers.sh
#
# It drives the running app over real HTTP with curl + a cookie jar (a real
# session, exactly how a browser hits it) and asserts side effects against the
# MySQL DB. See SKILL.md for the why and the gotchas.
#
# Overridable via env before sourcing:
#   BASE   - app root URL          (default http://localhost:8080)
#   MYSQL  - path to mysql client  (default XAMPP's mysql.exe)
#   DBNAME - schema                (default mathify_db)

BASE="${BASE:-http://localhost:8080}"
MYSQL="${MYSQL:-C:/xampp/mysql/bin/mysql.exe}"
DBNAME="${DBNAME:-mathify_db}"

PASS=0
FAIL=0

# --- DB access ----------------------------------------------------------------
# db "<sql>"         -> raw rows (tab-separated, no header). For multi-col/row.
# db_scalar "<sql>"  -> single value with ALL whitespace stripped. For counts/ids.
db()        { "$MYSQL" -uroot "$DBNAME" -N -e "$1" 2>/dev/null | tr -d '\r'; }
db_scalar() { "$MYSQL" -uroot "$DBNAME" -N -e "$1" 2>/dev/null | tr -d '[:space:]'; }

# --- assertions ---------------------------------------------------------------
# chk "label" actual expected           -> exact-equality assert
# chk_grep "label" file "pattern"        -> assert file contains pattern
# chk_missing "label" file "pattern"     -> assert file does NOT contain pattern
chk() {
  if [ "$2" = "$3" ]; then echo "  PASS: $1"; PASS=$((PASS+1))
  else echo "  FAIL: $1 (got '$2' expected '$3')"; FAIL=$((FAIL+1)); fi
}
chk_grep() {
  if grep -q "$3" "$2"; then echo "  PASS: $1"; PASS=$((PASS+1))
  else echo "  FAIL: $1 (pattern '$3' absent from $2)"; FAIL=$((FAIL+1)); fi
}
chk_missing() {
  if grep -q "$3" "$2"; then echo "  FAIL: $1 (pattern '$3' present in $2)"; FAIL=$((FAIL+1))
  else echo "  PASS: $1"; PASS=$((PASS+1)); fi
}

# --- lifecycle ----------------------------------------------------------------
# Poll until Tomcat answers. Returns non-zero on timeout.
wait_up() {
  for i in $(seq 1 60); do
    [ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/login.jsp")" = "200" ] \
      && { echo "  app UP after ${i} probe(s)"; return 0; }
    sleep 2
  done
  echo "  TIMEOUT: app never came up on $BASE"; return 1
}

# Kill the Tomcat on 8080 AND the orphaned mvn cargo:run launcher it leaves
# behind. Leaves XAMPP's mysqld alone.
stop_tomcat() {
  local pid
  pid=$(netstat -ano | grep ":8080 " | grep LISTENING | head -1 | awk '{print $NF}')
  [ -n "$pid" ] && taskkill //PID "$pid" //F >/dev/null 2>&1 && echo "  stopped Tomcat (pid $pid)"
  # cargo:run's maven launcher (plexus-classworlds) keeps running once its child dies.
  for mpid in $(powershell.exe -NoProfile -Command \
      "Get-CimInstance Win32_Process -Filter \"Name='java.exe'\" | Where-Object { \$_.CommandLine -like '*plexus-classworlds*' } | Select-Object -ExpandProperty ProcessId" 2>/dev/null | tr -d '\r'); do
    taskkill //PID "$mpid" //F >/dev/null 2>&1 && echo "  stopped maven launcher (pid $mpid)"
  done
  netstat -ano | grep ":8080 " | grep -q LISTENING && echo "  WARN: 8080 still bound" || echo "  port 8080 free"
}

# --- auth (the contracts that actually work) ----------------------------------
# Admin: seeded by database/insert_admin.sql (default demo creds, not a secret).
login_admin() {                       # login_admin <cookie_jar>
  curl -s -c "$1" -o /dev/null -d "email=admin@mathify.com&password=admin123" "$BASE/login"
  grep -q JSESSIONID "$1"
}
# Register fields are fullName / email / password / terms=on  (NOT name, NOT
# confirmPassword - using the wrong names silently fails registration). Then log
# in to get a usable student session in the jar.
new_student() {                       # new_student <cookie_jar> <email> <password> [name]
  local jar="$1" email="$2" pass="$3" name="${4:-E2E Student}"
  curl -s -c "$jar" -o /dev/null \
    --data-urlencode "fullName=$name" --data-urlencode "email=$email" \
    --data-urlencode "password=$pass" --data-urlencode "terms=on" "$BASE/register"
  curl -s -c "$jar" -o /dev/null \
    --data-urlencode "email=$email" --data-urlencode "password=$pass" "$BASE/login"
  [ "$(db_scalar "SELECT COUNT(*) FROM users WHERE email='$email';")" = "1" ]
}

# --- cleanup ------------------------------------------------------------------
# Remove throwaway rows. Convention: student emails start 'e2e_', seeded content
# rows carry an 'E2E ' prompt/title prefix. ON DELETE CASCADE clears children.
cleanup_test_data() {
  db "DELETE FROM users WHERE email LIKE 'e2e\\_%';" >/dev/null 2>&1
  db "DELETE FROM questions WHERE prompt LIKE 'E2E %';" >/dev/null 2>&1
  echo "  cleaned e2e_ users and 'E2E ' test questions"
}

# --- result -------------------------------------------------------------------
# Print totals; return non-zero if anything failed (CI-friendly).
summary() {
  echo ""
  echo "===== $PASS passed, $FAIL failed ====="
  [ "$FAIL" -eq 0 ]
}
