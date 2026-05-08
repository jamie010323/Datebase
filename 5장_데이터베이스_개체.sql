#날짜 : 2026/05/08
#이름 : 강현주
#내용 : 5장 데이터베이스 개체

#실습 5-1
SHOW INDEX FROM User1;
SHOW INDEX FROM User2;
SHOW INDEX FROM User3;
SELECT * FROM User3;

#실습 5-2
CREATE INDEX idx_user1_userid ON User1(userid);
ANALYZE TABLE User1;

#실습 5-3
DROP INDEX idx_user1_userid ON User1;

#실습 5-4
CREATE VIEW vw_user1 AS (SELECT name, hp, age FROM User1);
SELECT * FROM vw_user1;

CREATE VIEW vw_user4_age_under30 AS (SELECT * FROM User4 WHERE age < 30);
SELECT * FROM vw_user4;
CREATE VIEW vw_Employee_with_sales AS (
	SELECT
    a.empno AS 직원번호,
    b.name AS 직원이름,
    b.job AS 직급,
    c.dname AS 부서명,
    a.year AS 매출년도,
    a.month AS 월,
    a.price AS 매출액
FROM Sale AS a
JOIN Employee AS b ON a.empno = b.empno
JOIN Dept AS c ON b.depno = c.depNo    
);

#실습 5-5
SELECT * FROM vw_employee_with_sales;
SELECT * FROM vw_user4_age_under30;
SELECT * FROM vw_Employee_with_sales;

#실습 5-6
DROP VIEW vw_user1;
DROP VIEW vw_user4_age_under30;

#실습 5-7
DELIMITER $$
	CREATE PROCEDURE proc_test1()
    BEGIN
		SELECT*FROM Employee;
		SELECT*FROM Dept;
    END $$
DELIMITER ;

CALL proc_test1() -- 프로시저 호출

#실습 5-8

DELIMITER $$
	CREATE PROCEDURE proc_test2(IN_userName VARCHAR(10))
    BEGIN
		SELECT * FROM Employee WHERE name = _userName;
	END $$
DELIMITER ;

CALL proc_test3('김유신');

DELIMITER $$
	CREATE PROCEDURE proc_test3(IN_job VARCHAR(10), IN_depno TINYINT)
    BEGIN
		SELECT * FROM Employee WHERE job =_job AND depno=_depno;
	END $$
DELIMITER ;

CALL proc_test3('차장', 101);

DELIMITER $$
	CREATE PROCEDURE proc_test4(IN_job VARCHAR(10), OUT_count INT)
    BEGIN
		SELECT COUNT(*) INTO_count FROM Employee WHERE job =_job;
	END $$
DELIMITER ;

CALL proc_test4('대리', @_count);
SELECT CONCAT('_count ; ' , @_count);

#실습 5-9
DELIMITER $$
	CREATE PROCEDURE proc_test5(IN_name VARCHAR(10))
    BEGIN
		DECLARE _empno INT;
        SELECT empno into _empno FROM Employee WHERE name =_name;
        SELECT * FROM Sale WHERE empno = _empno;
	END $$
DELIMITER ;

CALL proc_test5('김유신');

DELIMITER $$
	CREATE PROCEDURE proc_test6()
    BEGIN
		DECLARE num1 INT;
        DECLARE num2 INT;
        
        SET num1 = 1; -- 값 할당
        SET num2 = 2; -- 값 할당
        
        IF (NUM1 > NUM2) THEN
			SELECT 'NUM1이 NUM2보다 크다.' as 결과2;
		else
			SELECT 'NUM1이 NUM2보다 작다.' as 결과2;
		END IF;
	END $$
DELIMITER ;
    
CALL proc_test6();

DELIMITER $$
	CREATE PROCEDURE proc_test7()
    BEGIN
		DECLARE sum INT;
		DECLARE num INT;
        
        SET sum = 0;
        SET sum = 1;
        
        WHILE (num <= 10) DO
			SET sum = sum + num;
            SET num = num+1;
		END WHILE;
        
        SELECT sum AS '1부터 10까지 합계';
	END $$
DELIMITER ;
    
CALL proc_test7(); 

#실습 5-10 커서를 활용한 프로시저

DELIMITER $$
	CREATE PROCEDURE proc_test8()
    BEGIN
		#변수 선언
        DECLARE total INT DEFAULT 0;
        DECLARE temp INT;
        DECLARE endOfRow BOOLEAN DEFAULT false;
        
        #커서 선언 : 테이블의 특정 컬럼을 포인팅하는(price) 가상개체 
        DECLARE saleCursor CURSOR FOR
			SELECT price FROM Sale;
            
	    #반복 조건
        DECLARE CONTINUE HANDLER
			FOR NOT FOUND SET endOfRow = TRUE;
		#커서 열기
        OPEN saleCursor;
        
        Cursor_loop: LOOP
        
			-- 커서가 가리키는 현재 행의 값을 temp 변수에 저장, 한번 반복마다 한행씩 이동
			FETCH saleCursor INTO temp;
            
            IF endOfRow THEN
				LEAVE cursor_loop;
			END IF;
            
            SET total = total + temp;
		END LOOP;
        
        SELECT total AS '전체 합계';
        
        CLOSE saleCursor;
            
    END $$
DELIMITER ;

CALL proc_test8();

SELECT price FROM Sale;

#실습 5-11
-- root로 접속해서 실행
DELIMITER $$
	CREATE FUNCTION func_test1(_empno INT) RETURNS INT
    BEGIN
		DECLARE total INT;
        
        SELECT SUM(price) INTO total FROM Sale WHERE empno = _empno;
        
        RETURN total;
    
    END $$
    
DELIMITER ;

SELECT func_test1(1001);  -- 함수는 SELECT, 프로시저는 CALL

DELIMITER $$
	CREATE FUNCTION func_test2(_price INT) RETURNS DOUBLE
    BEGIN
		DECLARE bonus DOUBLE;
    
    IF (_price >= 100000) THEN
		SET bonus = _price * 0.1;
	ELSE
		SET bonus = _price * 0.05;
	END IF;

	RETURN bonus;
	END $$
DELIMITER ;

SELECT
	empno,
    year,
    month,
    price,
    func_test2(sale) AS bonus
FROM Sale;

