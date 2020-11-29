use kakaopay;
show tables;
select * from dutchpay_claim;
select * from a_payment_trx;

/*
더치페이를 요청한 유저 중 2019년 12월에 1만원 이상 결제한 user_id를 추출하는 SQL 쿼리
- 2019년 12월 결제분 중 취소를 반영한 순결제금액 1만원 이상인 유저만을 대상
- 취소 반영기간은 2020년 2월까지로 함

취소는 그 전제로 결제가 있었으므로, 결제-취소는 같은 transaction_id를 공유한다.
따라서 CANCEL이 있으면 항상 그에 대응(=transaction_id)하는 PAYMENT가 있다.
결과적으로, payment_action_type PAYMENT 결제액(amount)에서
중복되는 payment_action_type CANCEL 결제액(amount)을 제외하면
취소가 발생하지 않은 결제, 즉 순결제금액이 된다.

본 쿼리에서는 더치페이를 요청한 유저 중 2019-12-01 ~ 2019-12-31 사이 PAYMENT 집합과
더치페이를 요청한 유저 중 2019-12-01 ~ 2020-02-29 사이 CANCEL 집합의 차집합에서
2019-12-01 ~ 2019-12-31 총 amount가 1만원 이상인 지급대상자 user_id를 추출하였다.
(MINUS 함수가 mysql에 없어 LEFT OUTER JOIN으로 구현) 
*/

SELECT 		DISTINCT d.claim_user_id AS reward_user_id

FROM 		dutchpay_claim d, 
			(SELECT * 
            		FROM 	a_payment_trx
			WHERE 	transacted_at >= '2019-12-01' AND transacted_at <= '2019-12-31'
			AND	payment_action_type = 'PAYMENT') p
            
	LEFT OUTER JOIN (SELECT * 
			FROM 	dutchpay_claim, 
				(SELECT * 
				FROM 	a_payment_trx
				WHERE 	transacted_at >= '2019-12-01' AND transacted_at <= '2020-02-29'
				AND	payment_action_type = 'CANCEL') p_cancel) p_CANCEL
                        
	ON		p.user_id = p_CANCEL.user_id
	WHERE		p_CANCEL.user_id IS NULL

GROUP BY 	d.claim_user_id

HAVING 		SUM(p.amount) >= 10000;


/* 취소가 발생할 경우 동일한 transaction_id가 중복하여 발생한다.
결제분 중 취소된 내역이 있으면 같은 transaction_id가 2개 이상 있다
ex: transaction_id 두개, payment_action_type은 PAYMENT/ CANCEL, amount는 동일

transaction_id가 2개 이상 존재하면 전부 제거하고(중복대상은 2020년 2월까지 고려)
transaction_id가 딱 하나 나오는것만 남기는 방법은? (distinct는 아니다 : 1건으로 처리)
*/
/*
SELECT 		DISTINCT d.claim_user_id AS reward_user_id
FROM 		dutchpay_claim d 
LEFT JOIN	a_payment_trx p
WHERE 		p.payment_action_type 
*/
