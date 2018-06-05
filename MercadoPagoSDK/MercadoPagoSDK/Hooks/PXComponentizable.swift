//
//  PXComponentizable.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
@objc
public protocol PXComponentizable {
    func render() -> UIView
}

@objc
public protocol PXCustomComponentizable {
    func render(store: PXCheckoutStore, theme: PXTheme) -> UIView?
}