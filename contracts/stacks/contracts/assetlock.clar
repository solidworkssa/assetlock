;; ────────────────────────────────────────
;; AssetLock v1.0.0
;; Author: solidworkssa
;; License: MIT
;; ────────────────────────────────────────

(define-constant VERSION "1.0.0")

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-INPUT (err u422))

;; AssetLock Clarity Contract
;; Time-locked asset vesting contract.


(define-map locks
    uint
    {
        owner: principal,
        amount: uint,
        unlock-height: uint
    }
)
(define-data-var lock-nonce uint u0)

(define-public (lock (amount uint) (duration uint))
    (let ((id (var-get lock-nonce)))
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set locks id {
            owner: tx-sender,
            amount: amount,
            unlock-height: (+ block-height duration)
        })
        (var-set lock-nonce (+ id u1))
        (ok id)
    )
)

(define-public (unlock (id uint))
    (let ((l (unwrap! (map-get? locks id) (err u404))))
        (asserts! (is-eq tx-sender (get owner l)) (err u401))
        (asserts! (>= block-height (get unlock-height l)) (err u100))
        (try! (as-contract (stx-transfer? (get amount l) tx-sender (get owner l))))
        (map-delete locks id)
        (ok true)
    )
)

