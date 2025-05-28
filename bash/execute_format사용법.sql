
이제 EXECUTE format()의 고급 활용법 몇 가지를 알려드릴게요. 아래는 PL/pgSQL에서 동적 SQL을 결과에 저장하거나 반복하거나 커서로 처리하는 방식입니다.

✅ 1. EXECUTE ... INTO — 결과를 변수에 저장
동적 SQL을 실행하고 결과를 하나의 변수에 담고 싶을 때 사용합니다.

sql
복사
편집
DO $$
DECLARE
    table_name text := 'users';
    user_name text;
BEGIN
    EXECUTE format('SELECT name FROM %I WHERE id = 1', table_name)
    INTO user_name;

    RAISE NOTICE '이름: %', user_name;
END $$;
%I는 테이블 이름 등 식별자용.

INTO는 일반 SELECT문의 결과 1개를 저장합니다.

✅ 2. EXECUTE ... INTO RECORD — 여러 컬럼을 한꺼번에 저장
sql
복사
편집
DO $$
DECLARE
    rec RECORD;
    tbl text := 'employees';
BEGIN
    EXECUTE format('SELECT id, name FROM %I WHERE id = 10', tbl)
    INTO rec;

    RAISE NOTICE 'ID: %, 이름: %', rec.id, rec.name;
END $$;
✅ 3. FOR rec IN EXECUTE ... — 여러 행 반복 처리
sql
복사
편집
DO $$
DECLARE
    rec RECORD;
    tbl text := 'products';
BEGIN
    FOR rec IN EXECUTE format('SELECT id, name FROM %I WHERE price > 100', tbl)
    LOOP
        RAISE NOTICE '상품: %, 가격 ID: %', rec.name, rec.id;
    END LOOP;
END $$;
다중 결과 행을 루프를 돌면서 처리합니다.

커서를 열지 않고 직접 반복 가능.

✅ 4. 동적 SQL + RETURNING
INSERT, UPDATE, DELETE 등에 대한 결과를 변수로 받고 싶을 때:

sql
복사
편집
DO $$
DECLARE
    tbl text := 'logs';
    inserted_id int;
BEGIN
    EXECUTE format('INSERT INTO %I(message) VALUES (%L) RETURNING id', tbl, 'Something happened')
    INTO inserted_id;

    RAISE NOTICE '삽입된 ID: %', inserted_id;
END $$;
✅ 5. 커서(CURSOR)와 동적 SQL 결합
sql
복사
편집
DO $$
DECLARE
    ref refcursor;
    row RECORD;
BEGIN
    OPEN ref FOR EXECUTE 'SELECT * FROM users WHERE id < 5';
    
    LOOP
        FETCH ref INTO row;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '유저: %', row.name;
    END LOOP;

    CLOSE ref;
END $$;
커서를 사용하면 외부 애플리케이션과 연동 시 더 정밀하게 제어 가능

🔁 동적 반복 쿼리 팁
반복되는 INSERT/UPDATE의 구조를 EXECUTE format(...)으로 감싸면 유연하게 처리 가능

LOOP와 EXECUTE를 결합해 조건별 동적 쿼리 실행 가능

🔒 보안/안정성 팁
상황	타입
테이블/컬럼 이름	%I (identifier)
값 (문자열/숫자)	%L (literal)
SQL 조각 직접 삽입	%s (주의: SQL 인젝션 위험!)

필요하시다면:

트랜잭션 안에서의 동적 쿼리 처리

임시 테이블 생성과 사용

함수 내 동적 테이블명 처리

같은 고급 케이스도 예시와 함께 설명드릴 수 있어요. 필요한 상황 말씀해주세요!