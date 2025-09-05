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

;; Allows users to stake STX on Bitcoin price direction
(define-public (cast-prediction
    (market-id uint)
    (direction (string-ascii 4))
    (stake-amount uint)
  )
  (let (
      (market-data (unwrap! (map-get? prediction-markets market-id) ERR_NOT_FOUND))
      (current-height stacks-block-height)
    )
    ;; Validate market timing and parameters
    (asserts!
      (and
        (>= current-height (get market-start market-data))
        (< current-height (get market-end market-data))
      )
      ERR_MARKET_INACTIVE
    )
    (asserts! (or (is-eq direction "bull") (is-eq direction "bear"))
      ERR_INVALID_PREDICTION
    )
    (asserts! (>= stake-amount (var-get minimum-stake)) ERR_INVALID_PARAMETER)
    (asserts! (<= stake-amount (stx-get-balance tx-sender))
      ERR_INSUFFICIENT_BALANCE
    )

    ;; Transfer stake to protocol
    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))

    ;; Record participant stake
    (map-set participant-stakes {
      market-id: market-id,
      participant: tx-sender,
    } {
      price-direction: direction,
      stake-amount: stake-amount,
      rewards-claimed: false,
    })

    ;; Update market pools
    (map-set prediction-markets market-id
      (merge market-data {
        bull-pool: (if (is-eq direction "bull")
          (+ (get bull-pool market-data) stake-amount)
          (get bull-pool market-data)
        ),
        bear-pool: (if (is-eq direction "bear")
          (+ (get bear-pool market-data) stake-amount)
          (get bear-pool market-data)
        ),
      })
    )

    (ok true)
  )
)

;; Oracle resolves market with final Bitcoin price
(define-public (settle-market
    (market-id uint)
    (closing-price uint)
  )
  (let ((market-data (unwrap! (map-get? prediction-markets market-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (var-get oracle-address)) ERR_UNAUTHORIZED)
    (asserts! (>= stacks-block-height (get market-end market-data))
      ERR_MARKET_INACTIVE
    )
    (asserts! (not (get is-resolved market-data)) ERR_MARKET_INACTIVE)
    (asserts! (> closing-price u0) ERR_INVALID_PARAMETER)

    (map-set prediction-markets market-id
      (merge market-data {
        final-price: closing-price,
        is-resolved: true,
      })
    )

    (ok true)
  )
)

;; Participants claim rewards from successful predictions
(define-public (claim-prediction-rewards (market-id uint))
  (let (
      (market-data (unwrap! (map-get? prediction-markets market-id) ERR_NOT_FOUND))
      (stake-data (unwrap!
        (map-get? participant-stakes {
          market-id: market-id,
          participant: tx-sender,
        })
        ERR_NOT_FOUND
      ))
    )
    (asserts! (get is-resolved market-data) ERR_MARKET_NOT_RESOLVED)
    (asserts! (not (get rewards-claimed stake-data)) ERR_ALREADY_CLAIMED)

    (let (
        (price-increased (> (get final-price market-data) (get initial-price market-data)))
        (winning-direction (if price-increased
          "bull"
          "bear"
        ))