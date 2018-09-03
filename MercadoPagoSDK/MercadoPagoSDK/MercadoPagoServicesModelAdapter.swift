//
//  MercadoPagoServicesModelAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

internal extension MercadoPagoServicesAdapter {

    internal func getPXSiteFromId(_ siteId: String) -> PXSite {
        let currency = SiteManager.shared.getCurrency()
        let pxSite = PXSite(id: siteId, currencyId: currency.id)
        return pxSite
    }

    internal func getCheckoutPreferenceFromPXCheckoutPreference(_ pxCheckoutPreference: PXCheckoutPreferenceNew) -> PXCheckoutPreference {
        let checkoutPreference = PXCheckoutPreference(siteId: pxCheckoutPreference.siteId ?? "", payerEmail: "", items: [])
        checkoutPreference.preferenceId = pxCheckoutPreference.id
        if let pxCheckoutPreferenceItems = pxCheckoutPreference.items {
            for pxItem in pxCheckoutPreferenceItems {
                let item = getItemFromPXItem(pxItem)
                checkoutPreference.items = Array.safeAppend(checkoutPreference.items, item)
            }
        }
        checkoutPreference.payer = pxCheckoutPreference.payer
        checkoutPreference.differentialPricing = pxCheckoutPreference.differentialPricing
        checkoutPreference.paymentPreference = getPaymentPreferenceFromPXPaymentPreference(pxCheckoutPreference.paymentPreference)
        checkoutPreference.expirationDateFrom = pxCheckoutPreference.expirationDateFrom ?? Date()
        checkoutPreference.expirationDateTo = pxCheckoutPreference.expirationDateTo ?? Date()
        return checkoutPreference
    }

    internal func getItemFromPXItem(_ pxItem: PXItemNew) -> PXItem {
        let id: String = pxItem.id
        let title: String = pxItem.title ?? ""
        let quantity: Int = pxItem.quantity ?? 1
        let unitPrice: Double = pxItem.unitPrice ?? 0.0
        let picture_URL: String = pxItem.pictureUrl ?? ""
        let item = PXItem(title: title, quantity: quantity, unitPrice: unitPrice)
        item.pictureUrl = picture_URL
        item.setDescription(description: pxItem._description ?? "")
        item.itemId = id
        return item
    }

    internal func getPaymentPreferenceFromPXPaymentPreference(_ pxPaymentPreference: PXPaymentPreference?) -> PaymentPreference {
        let paymentPreference = PaymentPreference()
        if let pxPaymentPreference = pxPaymentPreference {
            paymentPreference.excludedPaymentMethodIds = Set(pxPaymentPreference.excludedPaymentMethodIds ?? [])
            paymentPreference.excludedPaymentTypeIds = Set(pxPaymentPreference.excludedPaymentTypeIds ?? [])
            paymentPreference.defaultPaymentMethodId = pxPaymentPreference.defaultPaymentMethodId
            paymentPreference.maxAcceptedInstallments = pxPaymentPreference.maxAcceptedInstallments != nil ? pxPaymentPreference.maxAcceptedInstallments! : paymentPreference.maxAcceptedInstallments
            paymentPreference.defaultInstallments = pxPaymentPreference.defaultInstallments != nil ? pxPaymentPreference.defaultInstallments! : paymentPreference.defaultInstallments
            paymentPreference.defaultPaymentTypeId = pxPaymentPreference.defaultPaymentTypeId
        }
        return paymentPreference
    }

    internal func getPXCardTokenFromCardToken(_ cardToken: CardToken) -> PXCardToken {
        let pxCardToken = PXCardToken()
        pxCardToken.cardholder = cardToken.cardholder
        pxCardToken.cardNumber = cardToken.cardNumber
        pxCardToken.device = getPXDeviceFromDevice(cardToken.device)
        pxCardToken.expirationMonth = cardToken.expirationMonth
        pxCardToken.expirationYear = cardToken.expirationYear
        pxCardToken.securityCode = cardToken.securityCode
        return pxCardToken
    }

    internal func getPXSavedESCCardTokenFromSavedESCCardToken(_ savedESCCardToken: SavedESCCardToken) -> PXSavedESCCardToken {
        let pxSavedESCCardToken = PXSavedESCCardToken()
        pxSavedESCCardToken.cardId = savedESCCardToken.cardId
        pxSavedESCCardToken.securityCode = savedESCCardToken.securityCode
        pxSavedESCCardToken.device = PXDevice()
        pxSavedESCCardToken.requireEsc = savedESCCardToken.requireESC
        pxSavedESCCardToken.esc = savedESCCardToken.esc
        return pxSavedESCCardToken
    }

    internal func getPXSavedCardTokenFromSavedCardToken(_ savedCardToken: SavedCardToken) -> PXSavedCardToken {
        let pxSavedCardToken = PXSavedCardToken()
        pxSavedCardToken.cardId = savedCardToken.cardId
        pxSavedCardToken.securityCode = savedCardToken.securityCode
        pxSavedCardToken.device = getPXDeviceFromDevice(savedCardToken.device)
        return pxSavedCardToken
    }

    internal func getPXDeviceFromDevice(_ device: Device?) -> PXDevice {
        if let device = device {
            let pxDevice = PXDevice()
            pxDevice.fingerprint = getPXFingerprintFromFingerprint(device.fingerprint)
            return pxDevice
        } else {
            return PXDevice()
        }
    }

    internal func getPXFingerprintFromFingerprint(_ fingerprint: Fingerprint) -> PXFingerprint {
        let pxFingerprint = PXFingerprint()
        return pxFingerprint
    }

    func getStringDateFromDate(_ date: Date) -> String {
        let stringDate = String(describing: date)
        return stringDate
    }

    internal func getPaymentFromPXPayment(_ pxPayment: PXPaymentNew) -> PXPayment {
        let payment = PXPayment()
        payment.binaryMode = pxPayment.binaryMode
        payment.callForAuthorizeId = pxPayment.callForAuthorizeId
        payment.captured = pxPayment.captured
        payment.card = getCardFromPXCard(pxPayment.card)
        payment.currencyId = pxPayment.currencyId
        payment.dateApproved = pxPayment.dateApproved
        payment.dateCreated = pxPayment.dateCreated
        payment.dateLastUpdated = pxPayment.dateLastUpdated
        payment.paymentDescription = pxPayment._description
        payment.externalReference = pxPayment.externalReference

        if let pxPaymentFeeDetails = pxPayment.feeDetails {
            for pxFeeDetail in pxPaymentFeeDetails {
                let feesDetail = getFeesDetailFromPXFeeDetail(pxFeeDetail)
                payment.feesDetails = Array.safeAppend(payment.feesDetails, feesDetail)
            }
        }

        payment.paymentId = pxPayment.id.stringValue
        payment.installments = pxPayment.installments ?? 1
        payment.liveMode = pxPayment.liveMode
        payment.metadata = pxPayment.metadata! as NSObject
        payment.moneyReleaseDate = pxPayment.moneyReleaseDate
        payment.notificationUrl = pxPayment.notificationUrl
        payment.payer = pxPayment.payer
        payment.paymentMethodId = pxPayment.paymentMethodId
        payment.paymentTypeId = pxPayment.paymentTypeId
        payment.statementDescriptor = pxPayment.statementDescriptor
        payment.status = pxPayment.status
        payment.statusDetail = pxPayment.statusDetail
        payment.transactionAmount = pxPayment.transactionAmount ?? 0.0
        payment.transactionAmountRefunded = pxPayment.transactionAmountRefunded ?? 0.0
        payment.transactionDetails = pxPayment.transactionDetails
        payment.collectorId = String(describing: pxPayment.collectorId)
        payment.couponAmount = pxPayment.couponAmount ?? 0.0
        payment.differentialPricingId = NSNumber(value: pxPayment.differentialPricingId ?? 0)
        payment.issuerId = Int(pxPayment.issuerId ?? "0") ?? 0
        payment.tokenId = pxPayment.tokenId
        return payment
    }

    internal func getFeesDetailFromPXFeeDetail(_ pxFeeDetail: PXFeeDetail) -> FeesDetail {
        let feesDetail = FeesDetail()
        feesDetail.amount = pxFeeDetail.amount ?? 0.0
        feesDetail.feePayer = pxFeeDetail.feePayer
        feesDetail.type = pxFeeDetail.type
        return feesDetail
    }

    internal func getEntityTypeFromId(_ entityTypeId: String?) -> EntityType? {
        if let entityTypeId = entityTypeId {
            let entityType = EntityType()
            entityType.entityTypeId = entityTypeId
            entityType.name = ""
            return entityType
        } else {
            return nil
        }
    }

    internal func getPaymentMethodSearchFromPXPaymentMethodSearch(_ pxPaymentMethodSearch: PXPaymentMethodSearch) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()

        if let pxPaymentMethodSearchPaymentMethodSearchItem = pxPaymentMethodSearch.paymentMethodSearchItem {
            paymentMethodSearch.groups = []
            for pxPaymentMethodSearchItem in pxPaymentMethodSearchPaymentMethodSearchItem {
                let paymentMethodSearchItem = pxPaymentMethodSearchItem
                paymentMethodSearch.groups = Array.safeAppend(paymentMethodSearch.groups, paymentMethodSearchItem)
            }
        }

        paymentMethodSearch.paymentMethods = pxPaymentMethodSearch.paymentMethods
        if let pxPaymentMethodSearchCards = pxPaymentMethodSearch.cards {
            paymentMethodSearch.cards = []
            for pxCard in pxPaymentMethodSearchCards {
                let card = getCardFromPXCard(pxCard)
                paymentMethodSearch.cards = Array.safeAppend(paymentMethodSearch.cards, card)
            }
        }

        if let pxPaymentMethodSearchCustomOptionSearchItems = pxPaymentMethodSearch.customOptionSearchItems {
            paymentMethodSearch.customerPaymentMethods = []
            for pxCustomOptionSearchItem in pxPaymentMethodSearchCustomOptionSearchItems {
                let customerPaymentMethod = getCustomerPaymentMethodFromPXCustomOptionSearchItem(pxCustomOptionSearchItem)
                if let paymentMethodSearchCards = paymentMethodSearch.cards {
                    var filteredCustomerCard = paymentMethodSearchCards.filter({return $0.idCard == customerPaymentMethod.customerPaymentMethodId})
                    if !Array.isNullOrEmpty(filteredCustomerCard) {
                        customerPaymentMethod.card = filteredCustomerCard[0]
                    }
                }
                paymentMethodSearch.customerPaymentMethods = Array.safeAppend(paymentMethodSearch.customerPaymentMethods, customerPaymentMethod)
            }
        }

        if let pxDefaultOption = pxPaymentMethodSearch.defaultOption {
            paymentMethodSearch.defaultOption = pxPaymentMethodSearch.defaultOption
        }

        if let pxOneTap = pxPaymentMethodSearch.oneTap {
            paymentMethodSearch.oneTap = pxPaymentMethodSearch.oneTap
        }
        return paymentMethodSearch
    }

    internal func getCustomerPaymentMethodFromPXCustomOptionSearchItem(_ pxCustomOptionSearchItem: PXCustomOptionSearchItem) -> CustomerPaymentMethod {
        let id: String = pxCustomOptionSearchItem.id
        let paymentMethodId: String = pxCustomOptionSearchItem.paymentMethodId ?? ""
        let paymentMethodTypeId: String = pxCustomOptionSearchItem.paymentTypeId ?? ""
        let description: String = pxCustomOptionSearchItem._description ?? ""
        let customerPaymentMethod = CustomerPaymentMethod(cPaymentMethodId: id, paymentMethodId: paymentMethodId, paymentMethodTypeId: paymentMethodTypeId, description: description)
        return customerPaymentMethod
    }

    internal func getCardFromPXCard(_ pxCard: PXCard?) -> Card {
        let card = Card()
        if let pxCard = pxCard {
            card.cardHolder = pxCard.cardHolder
            card.customerId = pxCard.customerId
            card.dateCreated = pxCard.dateCreated
            card.dateLastUpdated = pxCard.dateLastUpdated
            card.expirationMonth = pxCard.expirationMonth ?? 0
            card.expirationYear = pxCard.expirationYear ?? 0
            card.firstSixDigits = pxCard.firstSixDigits
            card.idCard = pxCard.id ?? ""
            card.lastFourDigits = pxCard.lastFourDigits
            card.paymentMethod = pxCard.paymentMethod
            card.issuer = pxCard.issuer
            card.securityCode = pxCard.securityCode
            return card
        }
        return card
    }

    internal func getCustomerFromPXCustomer(_ pxCustomer: PXCustomer) -> Customer {
        let customer = Customer()

        if let pxCustomerCards = pxCustomer.cards {
            customer.cards = []
            for pxCard in pxCustomerCards {
                let card = getCardFromPXCard(pxCard)
                customer.cards = Array.safeAppend(customer.cards, card)
            }
        }

        customer.defaultCard = pxCustomer.defaultCard
        customer.customerDescription = pxCustomer._description
        customer.dateCreated = pxCustomer.dateCreated
        customer.dateLastUpdated = pxCustomer.dateLastUpdated
        customer.email = pxCustomer.email
        customer.firstName = pxCustomer.firstName
        customer.customerId = pxCustomer.id
        customer.identification = pxCustomer.identification
        customer.lastName = pxCustomer.lastName
        customer.liveMode = pxCustomer.liveMode
        customer.phone = getPhoneFromPXPhone(pxCustomer.phone)
        customer.registrationDate = pxCustomer.registrationDate

        if let meta = pxCustomer.metadata {
            customer.metadata = meta as NSDictionary
        }
        return customer
    }

    internal func getPhoneFromPXPhone(_ pxPhone: PXPhone?) -> Phone {
        let phone = Phone()
        if let pxPhone = pxPhone {
            phone.areaCode = pxPhone.areaCode
            phone.number = pxPhone.number
        }
        return phone
    }
}
