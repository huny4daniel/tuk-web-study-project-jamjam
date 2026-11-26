-- =========================================================
--  조식 추가 기능용 스크립트 (이미 쓰고 있는 hotel DB 에 한 번 실행)
--  HeidiSQL 에서 열고 전체 실행(F9). 기존 데이터는 지우지 않으며 여러 번 실행해도 됩니다.
--  db/hotel.sql 로 처음부터 새로 만들 때는 실행하지 않아도 됩니다.
-- =========================================================
SET NAMES utf8mb4;
USE hotel;

-- 예약에 조식 추가 인원·금액 컬럼 (이미 있으면 건너뜀)
SET @has := (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = 'hotel' AND table_name = 'reservation' AND column_name = 'breakfastCount');
SET @sql := IF(@has = 0,
	'ALTER TABLE reservation ADD COLUMN breakfastCount INT NOT NULL DEFAULT 0 AFTER totalPrice, ADD COLUMN breakfastPrice INT NOT NULL DEFAULT 0 AFTER breakfastCount',
	'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 자주 묻는 질문 답변에 조식 추가 안내
UPDATE faq SET answer = '조식은 2층 레스토랑에서 오전 7시 ~ 10시에 드실 수 있습니다. 조식 미포함 객실도 결제 화면의 [추가 옵션]에서 1인 1박 20,000원에 조식을 추가할 수 있습니다.'
WHERE question = '조식은 어디서 먹나요?';

-- 영어 화면 번역 (이미 있는 문구는 건너뜀)
INSERT IGNORE INTO translation (ko, en) VALUES
('추가 옵션', 'Add-ons'),
('조식 추가', 'Add breakfast'),
('조식 인원', 'Breakfast guests'),
('2층 레스토랑 07:00~10:00 · 1인 1박', '2F restaurant 07:00–10:00 · per person per night'),
('2층 레스토랑 07:00~10:00', '2F restaurant 07:00–10:00'),
('오늘 아침 조식', 'Today''s breakfast'),
('조식 미포함 · 결제 화면에서 1인 1박 20,000원에 추가할 수 있습니다', 'No breakfast · add it on the payment page for KRW 20,000 per person per night'),
('조식은 2층 레스토랑에서 오전 7시 ~ 10시에 드실 수 있습니다. 조식 미포함 객실도 결제 화면의 [추가 옵션]에서 1인 1박 20,000원에 조식을 추가할 수 있습니다.', 'Breakfast is served at the 2nd-floor restaurant from 7 to 10 AM. If your room does not include breakfast, you can add it on the payment page under [Add-ons] for KRW 20,000 per person per night.');
