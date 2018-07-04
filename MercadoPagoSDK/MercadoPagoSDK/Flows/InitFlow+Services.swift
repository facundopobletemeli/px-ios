//
//  InitFlow+Services.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 2/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension InitFlow {
    func getCheckoutPreference() {
        model.getService().getCheckoutPreference(checkoutPreferenceId: model.properties.checkoutPreference.preferenceId, callback: { [weak self] (checkoutPreference) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.model.properties.checkoutPreference = checkoutPreference
            strongSelf.model.properties.paymentData.payer = checkoutPreference.getPayer()
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_PREFERENCE, shouldRetry: true)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }

    func validatePreference() {
        let errorMessage = model.properties.checkoutPreference.validate()
        if errorMessage != nil {
            let customError = InitFlowError(errorStep: .ACTION_VALIDATE_PREFERENCE, shouldRetry: false)
            model.setError(error: customError)
        }
        executeNextStep()
    }

    func getDirectDiscount() {
        model.getService().getDirectDiscount(amount: model.amountHelper.amountToPay, payerEmail: model.properties.checkoutPreference.payer.email, callback: { [weak self] (_) in

            guard let strongSelf = self else {
                return
            }

            // TODO: SET DISCOUNT WITH CAMPAIGN
            // strongSelf.viewModel.paymentData.discount = discount
            strongSelf.executeNextStep()

            }, failure: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                let customError = InitFlowError(errorStep: .SERVICE_GET_DIRECT_DISCOUNT, shouldRetry: true)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }

    func initPaymentMethodPlugins() {
        if !model.properties.paymentMethodPlugins.isEmpty {
            initPlugin(plugins: model.properties.paymentMethodPlugins, index: model.properties.paymentMethodPlugins.count - 1)
        } else {
            executeNextStep()
        }
    }

    func initPlugin(plugins: [PXPaymentMethodPlugin], index: Int) {
        if index < 0 {
            DispatchQueue.main.async {
                self.model.paymentMethodPluginDidLoaded()
                self.executeNextStep()
            }
        } else {
            // TODO-JUAN: Ver que hacer con el copyViewModelAndAssignToCheckoutStore
            // _ = self.viewModel.copyViewModelAndAssignToCheckoutStore()
            let plugin = plugins[index]
            plugin.initPaymentMethodPlugin(PXCheckoutStore.sharedInstance, { [weak self] _ in
                self?.initPlugin(plugins: plugins, index: index - 1)
            })
        }
    }

    func getPaymentMethodSearch() {
        let paymentMethodPluginsToShow = model.properties.paymentMethodPlugins.filter {$0.mustShowPaymentMethodPlugin(PXCheckoutStore.sharedInstance) == true}
        var pluginIds = [String]()
        for plugin in paymentMethodPluginsToShow {
            pluginIds.append(plugin.getId())
        }

        let cardIdsWithEsc = model.getESCService().getSavedCardIds()
        let exclusions: MercadoPagoServicesAdapter.PaymentSearchExclusions = (model.getExcludedPaymentTypesIds(), model.getExcludedPaymentMethodsIds())
        let oneTapInfo: MercadoPagoServicesAdapter.PaymentSearchOneTapInfo = (cardIdsWithEsc, pluginIds)

        model.getService().getPaymentMethodSearch(amount: model.amountHelper.amountToPay, exclusions: exclusions, oneTapInfo: oneTapInfo, defaultPaymentMethod: model.getDefaultPaymentMethodId(), payer: Payer(), site: MercadoPagoContext.getSite(), callback: { [weak self] (paymentMethodSearch) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.model.updateInitModel(paymentMethodsResponse: paymentMethodSearch)
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }

                let customError = InitFlowError(errorStep: .SERVICE_GET_PAYMENT_METHODS, shouldRetry: true)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }
}
