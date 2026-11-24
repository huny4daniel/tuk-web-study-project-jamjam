-- =========================================================
--  결제수단 기능 추가용 스크립트 (이미 쓰고 있는 hotel DB 에 한 번 실행)
--  HeidiSQL 에서 열고 전체 실행(F9). 기존 데이터는 지우지 않으며 여러 번 실행해도 됩니다.
--  db/hotel.sql 로 처음부터 새로 만들 때는 실행하지 않아도 됩니다.
-- =========================================================
SET NAMES utf8mb4;
USE hotel;

-- 회원이 등록해 둔 결제수단 (모의 결제) : 결제 화면에서 골라서 씀
CREATE TABLE IF NOT EXISTS pay_card (
	cardId        INT          NOT NULL AUTO_INCREMENT,
	userId        VARCHAR(50)  NOT NULL,          -- 등록한 회원
	cardCompany   VARCHAR(20)  NOT NULL,          -- 카드사
	cardName      VARCHAR(30)  NOT NULL,          -- 별칭
	last4         CHAR(4)      NOT NULL,          -- 카드번호 끝 4자리 (전체 번호는 저장하지 않음)
	isDefault     TINYINT      NOT NULL DEFAULT 0,-- 결제 화면에서 먼저 선택되는 기본 카드면 1
	PRIMARY KEY (cardId)
);

-- 자주 묻는 질문 (같은 질문이 없을 때만)
INSERT INTO faq (category, question, answer)
SELECT '예약·결제', '카드를 등록해 두고 결제할 수 있나요?', '마이페이지 [결제수단]에 카드를 등록해 두면 결제 화면에서 원하는 카드를 골라 결제할 수 있습니다.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM faq WHERE question = '카드를 등록해 두고 결제할 수 있나요?');

-- 예전 문구로 이미 들어가 있으면 새 문구로 바꿈
UPDATE faq SET answer = '마이페이지 [결제수단]에 카드를 등록해 두면 결제 화면에서 원하는 카드를 골라 결제할 수 있습니다.'
WHERE answer = '마이페이지 [결제 카드]에 카드를 등록해 두면 결제 화면의 [원터치 결제] 버튼으로 기본 카드를 바로 사용할 수 있습니다.';

-- 영어 화면 번역 (이미 있는 문구는 건너뜀)
INSERT IGNORE INTO translation (ko, en) VALUES
('결제수단', 'Payment Methods'),
('결제수단 관리', 'Payment Methods'),
('카드 등록', 'Add a Card'),
('카드를 등록해 두면 결제 화면에서 골라 바로 결제할 수 있습니다. (최대 5장)', 'Save a card and pick it at checkout. (up to 5)'),
('카드번호 끝 4자리', 'Last 4 digits'),
('별칭 (선택)', 'Nickname (optional)'),
('※ 수업용 모의 결제라서 카드번호 전체, 유효기간, CVC 는 받지 않습니다.', '※ This is a mock payment for a class project. We never ask for the full card number, expiry date or CVC.'),
('등록한 카드', 'Saved Cards'),
('카드', 'Card'),
('별칭', 'Nickname'),
('기본 카드', 'Default card'),
('기본', 'Default'),
('기본으로 지정', 'Set as default'),
('등록한 카드가 없습니다.', 'No saved cards.'),
('등록 카드', 'Saved card'),
('다른 카드', 'Another card'),
('카드 번호', 'Card number'),
('마이페이지 > 결제수단', 'My Page > Payment Methods'),
('카드를 등록해 두고 결제할 수 있나요?', 'Can I save a card and pay with it?'),
('마이페이지 [결제수단]에 카드를 등록해 두면 결제 화면에서 원하는 카드를 골라 결제할 수 있습니다.', 'Yes. Save a card in My Page [Payment Methods], then choose the card you want at checkout.'),
('탈퇴하면 같은 아이디로 다시 로그인할 수 없고, 회원 정보와 등록한 투숙객·결제수단은 바로 삭제됩니다.', 'Once you leave, you cannot log in with the same ID, and your account details, saved guests and payment methods are deleted immediately.');
