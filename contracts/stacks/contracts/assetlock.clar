;; AssetLock - Time-locked vault

(define-data-var lock-counter uint u0)

(define-map locks uint {
    owner: principal,
    beneficiary: principal,
    amount: uint,
    unlock-block: uint,
    withdrawn: bool
})

(define-constant ERR-NOT-UNLOCKED (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))

(define-public (create-lock (beneficiary principal) (duration uint))
    (let ((lock-id (var-get lock-counter)))
        (try! (stx-transfer? tx-sender (as-contract tx-sender) tx-sender))
        (map-set locks lock-id {
            owner: tx-sender,
            beneficiary: beneficiary,
            amount: u0,
            unlock-block: (+ block-height duration),
            withdrawn: false
        })
        (var-set lock-counter (+ lock-id u1))
        (ok lock-id)))

(define-public (withdraw-lock (lock-id uint))
    (let ((lock (unwrap! (map-get? locks lock-id) ERR-UNAUTHORIZED)))
        (asserts! (is-eq (get beneficiary lock) tx-sender) ERR-UNAUTHORIZED)
        (asserts! (>= block-height (get unlock-block lock)) ERR-NOT-UNLOCKED)
        (ok true)))

(define-read-only (get-lock (lock-id uint))
    (ok (map-get? locks lock-id)))
