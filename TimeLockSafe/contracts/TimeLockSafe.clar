;; TimeLockSafe Contract
;; Allows users to deposit tokens and withdraw them only after a specified lock period.

;; Define constants for error messages
(define-constant ERR_INVALID_DURATION (err u1001))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1002))
(define-constant ERR_EARLY_WITHDRAWAL (err u1003))
(define-constant ERR_UNAUTHORIZED (err u1004))
(define-constant ERR_OVERFLOW (err u1005))
(define-constant ERR_INVALID_AMOUNT (err u1006))

;; Define constant for maximum lock duration (e.g., 1 year)
(define-constant MAX_LOCK_DURATION u52560)

;; Data maps to store user balances and lock periods
(define-map balances { user: principal } uint)
(define-map lock-periods { user: principal } uint)

;; Function to deposit tokens into the TimeLockSafe
(define-public (deposit (amount uint) (duration uint))
    (begin
        ;; Validate the deposit amount
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        ;; Validate the lock duration
        (asserts! (and (> duration u0) (<= duration MAX_LOCK_DURATION)) ERR_INVALID_DURATION)
        ;; Check for overflow when adding the lock period to the current block height
        (let ((unlock-height (+ block-height duration)))
            (asserts! (>= unlock-height block-height) ERR_OVERFLOW)
            ;; Transfer STX to the contract
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            ;; Update the user's balance and lock period
            (map-set balances { user: tx-sender } (+ (default-to u0 (map-get? balances { user: tx-sender })) amount))
            (map-set lock-periods { user: tx-sender } unlock-height)
            (ok "Deposit successful")
        )
    )
)

;; Function to withdraw tokens from the TimeLockSafe
(define-public (withdraw (amount uint))
    (begin
        ;; Check if the user has sufficient balance
        (let ((balance (default-to u0 (map-get? balances { user: tx-sender }))))
            (asserts! (>= balance amount) ERR_INSUFFICIENT_BALANCE)
            ;; Check if the lock period has expired
            (let ((unlock-height (default-to u0 (map-get? lock-periods { user: tx-sender }))))
                (asserts! (>= block-height unlock-height) ERR_EARLY_WITHDRAWAL)
                ;; Transfer the requested amount to the user and update their balance
                (try! (as-contract (stx-transfer? amount tx-sender (as-contract tx-sender))))
                (map-set balances { user: tx-sender } (- balance amount))
                (if (is-eq (- balance amount) u0)
                    (map-delete lock-periods { user: tx-sender })
                    true
                )
                (ok amount)
            )
        )
    )
)

;; Function to check a user's balance
(define-read-only (get-balance (user principal))
    (ok (default-to u0 (map-get? balances { user: user })))
)

;; Function to check a user's unlock height
(define-read-only (get-unlock-height (user principal))
    (ok (default-to u0 (map-get? lock-periods { user: user })))
)