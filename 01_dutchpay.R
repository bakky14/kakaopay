library(tidyverse)
# rm(list = ls())

users <- read_csv('users.csv')
dutchpay_claim <- read_csv('dutchpay_claim.csv')
dutchpay_claim_detail <- read_csv('dutchpay_claim_detail.csv')
# a_payment_trx <- read_csv('a_payment_trx.csv')

glimpse(users)
glimpse(dutchpay_claim)
glimpse(dutchpay_claim_detail)
# glimpse(a_payment_trx)
# 1) '더치페이 요청에 대한 응답률이 높을수록 더치페이 서비스를 더 많이 사용한다'
# 라는 가설을 통계적으로 검정하시오
# - 해당 가설 검정 방법을 선택한 이유와 함께 전체 검정 과정을 기술하시오

dutchpay_claim_total <- left_join(dutchpay_claim, dutchpay_claim_detail, 
                                  by = 'claim_id')
glimpse(dutchpay_claim_total)

users_dutchpay_claim_total <- left_join(dutchpay_claim_total, users,  
                                        by = c('claim_user_id' = 'user_id'))
glimpse(users_dutchpay_claim_total)


## 응답률의 정의 :
# 더치페이는 한 사람이 여러사람에게 요청한다. 
# 요청받은 사람들 중 응답(송금SEND) 한 숫자가 많을수록 응답률이 높다고 할 수 있다.

# 응답률 : claim_id당 status의 CLAIM 갯수 대비 SEND 갯수 비율


## claim_id당 status의 CLAIM 갯수
users_dutchpay_claim_total %>% 
    group_by(claim_id) %>%
    filter(status == 'CLAIM') %>% 
    summarise(claim_n = n()) -> users_dutchpay_claim_count
glimpse(users_dutchpay_claim_count)


## claim_id당 status의 SEND 갯수
users_dutchpay_claim_total %>% 
    group_by(claim_id) %>%
    filter(status == 'SEND') %>% 
    mutate(send_n = n()) -> users_dutchpay_send_count
glimpse(users_dutchpay_send_count)


users_dutchpay_claim_send <- left_join(users_dutchpay_claim_count, users_dutchpay_send_count)
glimpse(users_dutchpay_claim_send)


users_dutchpay_claim_send$send_n <- replace(users_dutchpay_claim_send$send_n, 
                                            is.na(users_dutchpay_claim_send$send_n),
                                            0)
users_dutchpay_claim_send %>% 
    select(claim_id, claim_n, send_n) %>%
    mutate(response = send_n / claim_n) -> users_dutchpay_response

glimpse(users_dutchpay_response)
hist(users_dutchpay_response$response)

## 더치페이 서비스 사용량의 정의 :
#  "더치페이 요청에 대한 응답률이 높을수록 더치페이 서비스를 '더 많이 사용'한다."
# 가설 문장의 맥락을 파악하면 '응답이 많을수록 요청기능을 더 많이 실행한다'라고 해석할 수 있다. 
# 여기서의 '사용'은 요청(CLAIM)을 의미한다.

## 사용량 : claim_id당 status의 CLAIM 갯수

length(users_dutchpay_claim_total$claim_id)
length(unique(users_dutchpay_claim_total$claim_id))

users_dutchpay_response %>% 
    group_by(claim_id) %>%
    summarize(claim_no = n()) -> users_dutchpay_usage

claim_response_usage <- left_join(users_dutchpay_usage, 
                                  users_dutchpay_response,
                                  by = 'claim_id')
glimpse(claim_response_usage)
summary(claim_response_usage)


## 상관분석
hist(claim_response_usage$response)
hist(claim_response_usage$claim_no)
plot(claim_response_usage$response, claim_response_usage$claim_no)

# 연속형 변수이므로 피어슨 상관계수를 선택하여 두 변수간의 선형적 상관관계를 검증한다.
cor.test(claim_response_usage$response, claim_response_usage$claim_no, 
         alternative=c('greater'), method = 'pearson')

cor(claim_response_usage$response, claim_response_usage$claim_no, method = 'pearson')

