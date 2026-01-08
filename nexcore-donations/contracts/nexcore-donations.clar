;; NexCore Donations - Transparent Charitable Giving Platform
;; Core contract for donations, impact tracking, and verification

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-already-verified (err u104))
(define-constant err-insufficient-balance (err u105))

;; Data Variables
(define-data-var total-donations uint u0)
(define-data-var total-projects uint u0)
(define-data-var min-donation-amount uint u1000000) ;; 1 STX minimum

;; Data Maps
(define-map projects
  { project-id: uint }
  {
    name: (string-ascii 100),
    beneficiary: principal,
    target-amount: uint,
    raised-amount: uint,
    impact-score: uint,
    verified: bool,
    active: bool,
    created-at: uint
  }
)

(define-map donations
  { donation-id: uint }
  {
    donor: principal,
    project-id: uint,
    amount: uint,
    timestamp: uint,
    impact-nft-minted: bool
  }
)

(define-map impact-validators
  { validator: principal }
  {
    reputation-score: uint,
    validations-count: uint,
    active: bool
  }
)

(define-map project-validations
  { project-id: uint, validator: principal }
  {
    impact-score: uint,
    evidence-hash: (string-ascii 64),
    timestamp: uint
  }
)

(define-map donor-stats
  { donor: principal }
  {
    total-donated: uint,
    projects-supported: uint,
    impact-nfts: uint
  }
)

;; Read-only functions
(define-read-only (get-project (project-id uint))
  (map-get? projects { project-id: project-id })
)

(define-read-only (get-donation (donation-id uint))
  (map-get? donations { donation-id: donation-id })
)

(define-read-only (get-validator (validator principal))
  (map-get? impact-validators { validator: validator })
)

(define-read-only (get-donor-stats (donor principal))
  (map-get? donor-stats { donor: donor })
)

(define-read-only (get-total-donations)
  (ok (var-get total-donations))
)

(define-read-only (get-total-projects)
  (ok (var-get total-projects))
)

(define-read-only (get-project-validation (project-id uint) (validator principal))
  (map-get? project-validations { project-id: project-id, validator: validator })
)

;; Public functions

;; Create a new charitable project
(define-public (create-project (name (string-ascii 100)) (target-amount uint))
  (let
    (
      (project-id (+ (var-get total-projects) u1))
    )
    (asserts! (> target-amount u0) err-invalid-amount)
    (map-set projects
      { project-id: project-id }
      {
        name: name,
        beneficiary: tx-sender,
        target-amount: target-amount,
        raised-amount: u0,
        impact-score: u0,
        verified: false,
        active: true,
        created-at: block-height
      }
    )
    (var-set total-projects project-id)
    (ok project-id)
  )
)

;; Make a donation to a project
(define-public (donate (project-id uint) (amount uint))
  (let
    (
      (project (unwrap! (get-project project-id) err-not-found))
      (donation-id (+ (var-get total-donations) u1))
      (current-stats (default-to 
        { total-donated: u0, projects-supported: u0, impact-nfts: u0 }
        (get-donor-stats tx-sender)
      ))
    )
    (asserts! (get active project) err-unauthorized)
    (asserts! (>= amount (var-get min-donation-amount)) err-invalid-amount)
    
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update project raised amount
    (map-set projects
      { project-id: project-id }
      (merge project { raised-amount: (+ (get raised-amount project) amount) })
    )
    
    ;; Record donation
    (map-set donations
      { donation-id: donation-id }
      {
        donor: tx-sender,
        project-id: project-id,
        amount: amount,
        timestamp: block-height,
        impact-nft-minted: false
      }
    )
    
    ;; Update donor stats
    (map-set donor-stats
      { donor: tx-sender }
      {
        total-donated: (+ (get total-donated current-stats) amount),
        projects-supported: (+ (get projects-supported current-stats) u1),
        impact-nfts: (get impact-nfts current-stats)
      }
    )
    
    (var-set total-donations donation-id)
    (ok donation-id)
  )
)

;; Register as an impact validator
(define-public (register-validator)
  (begin
    (map-set impact-validators
      { validator: tx-sender }
      {
        reputation-score: u100,
        validations-count: u0,
        active: true
      }
    )
    (ok true)
  )
)

;; Submit impact validation for a project
(define-public (submit-validation (project-id uint) (impact-score uint) (evidence-hash (string-ascii 64)))
  (let
    (
      (project (unwrap! (get-project project-id) err-not-found))
      (validator-info (unwrap! (get-validator tx-sender) err-unauthorized))
    )
    (asserts! (get active validator-info) err-unauthorized)
    (asserts! (<= impact-score u100) err-invalid-amount)
    
    ;; Record validation
    (map-set project-validations
      { project-id: project-id, validator: tx-sender }
      {
        impact-score: impact-score,
        evidence-hash: evidence-hash,
        timestamp: block-height
      }
    )
    
    ;; Update validator stats
    (map-set impact-validators
      { validator: tx-sender }
      (merge validator-info 
        { validations-count: (+ (get validations-count validator-info) u1) }
      )
    )
    
    ;; Update project impact score (simplified averaging)
    (map-set projects
      { project-id: project-id }
      (merge project { impact-score: impact-score })
    )
    
    (ok true)
  )
)

;; Verify and release funds to beneficiary
(define-public (release-funds (project-id uint))
  (let
    (
      (project (unwrap! (get-project project-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get beneficiary project)) err-unauthorized)
    (asserts! (get verified project) err-unauthorized)
    (asserts! (> (get raised-amount project) u0) err-insufficient-balance)
    
    ;; Transfer funds to beneficiary
    (try! (as-contract (stx-transfer? 
      (get raised-amount project) 
      tx-sender 
      (get beneficiary project)
    )))
    
    ;; Mark project as inactive
    (map-set projects
      { project-id: project-id }
      (merge project { 
        active: false,
        raised-amount: u0
      })
    )
    
    (ok true)
  )
)

;; Mark project as verified (owner only)
(define-public (verify-project (project-id uint))
  (let
    (
      (project (unwrap! (get-project project-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (get verified project)) err-already-verified)
    
    (map-set projects
      { project-id: project-id }
      (merge project { verified: true })
    )
    (ok true)
  )
)

;; Mint Impact NFT for donation (simplified)
(define-public (mint-impact-nft (donation-id uint))
  (let
    (
      (donation (unwrap! (get-donation donation-id) err-not-found))
      (donor-info (unwrap! (get-donor-stats (get donor donation)) err-not-found))
    )
    (asserts! (is-eq tx-sender (get donor donation)) err-unauthorized)
    (asserts! (not (get impact-nft-minted donation)) err-already-verified)
    
    ;; Update donation record
    (map-set donations
      { donation-id: donation-id }
      (merge donation { impact-nft-minted: true })
    )
    
    ;; Update donor stats
    (map-set donor-stats
      { donor: tx-sender }
      (merge donor-info { impact-nfts: (+ (get impact-nfts donor-info) u1) })
    )
    
    (ok true)
  )
)

;; Admin function to update minimum donation
(define-public (set-min-donation (new-min uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set min-donation-amount new-min)
    (ok true)
  )
)