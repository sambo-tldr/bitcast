;; BitCast Protocol - Decentralized Bitcoin Price Forecasting
;;
;; Summary: A sophisticated prediction market protocol that harnesses collective
;;          intelligence to forecast Bitcoin price movements on the Stacks blockchain
;;
;; Description: BitCast creates trustless prediction markets where participants stake
;;              STX tokens on Bitcoin price direction forecasts. The protocol leverages
;;              oracle price feeds for transparent resolution and distributes rewards
;;              proportionally to successful predictors. Built with enterprise-grade
;;              security, configurable parameters, and automated settlement mechanisms.
;;
;; Features:    - Decentralized price prediction markets
;;              - Oracle-based transparent resolution  
;;              - Proportional reward distribution
;;              - Configurable market parameters
;;              - Automated fee collection and withdrawal
;;              - Multi-timeframe prediction windows

;; CONSTANTS & ERROR HANDLING

;; Administrative Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INVALID_PREDICTION (err u102))
(define-constant ERR_MARKET_INACTIVE (err u103))
(define-constant ERR_ALREADY_CLAIMED (err u104))
(define-constant ERR_INSUFFICIENT_BALANCE (err u105))
(define-constant ERR_INVALID_PARAMETER (err u106))
(define-constant ERR_MARKET_NOT_RESOLVED (err u107))

;; STATE VARIABLES

;; Protocol Configuration
(define-data-var oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-data-var minimum-stake uint u1000000) ;; 1 STX minimum
(define-data-var platform-fee-rate uint u250) ;; 2.5% (250 basis points)
(define-data-var market-id-counter uint u0)

;; DATA STRUCTURES

;; Market Registry
(define-map prediction-markets
  uint
  {
    initial-price: uint,
    final-price: uint,
    bull-pool: uint, ;; Total stakes predicting price increase
    bear-pool: uint, ;; Total stakes predicting price decrease  
    market-start: uint, ;; Block height when market opens
    market-end: uint, ;; Block height when market closes
    is-resolved: bool,
  }
)

;; Participant Stakes Registry
(define-map participant-stakes
  {
    market-id: uint,
    participant: principal,
  }
  {
    price-direction: (string-ascii 4), ;; "bull" or "bear"
    stake-amount: uint,
    rewards-claimed: bool,
  }
)

;; CORE MARKET FUNCTIONS

;; Creates a new Bitcoin price prediction market
(define-public (launch-prediction-market
    (opening-price uint)
    (start-block uint)
    (end-block uint)
  )
  (let ((new-market-id (var-get market-id-counter)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (> end-block start-block) ERR_INVALID_PARAMETER)
    (asserts! (> opening-price u0) ERR_INVALID_PARAMETER)

    (map-set prediction-markets new-market-id {
      initial-price: opening-price,
      final-price: u0,
      bull-pool: u0,
      bear-pool: u0,
      market-start: start-block,
      market-end: end-block,
      is-resolved: false,
    })

    (var-set market-id-counter (+ new-market-id u1))
    (ok new-market-id)
  )
)