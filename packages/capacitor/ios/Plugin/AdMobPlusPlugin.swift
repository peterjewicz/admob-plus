import Foundation
import Capacitor
import GoogleMobileAds

@objc(AdMobPlusPlugin)
public class AdMobPlusPlugin: CAPPlugin {
    @objc func start(_ call: CAPPluginCall) {
        GADMobileAds.sharedInstance().start(completionHandler: { status in
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ kGADSimulatorID ] as? [String]

            call.resolve()
        })
        
    }
    
    @objc func bannerShow(_ call: CAPPluginCall) {
        if let banner = AMSBanner.getOrCreate(call) {
            DispatchQueue.main.async {
                banner.show(call, request: self.createGADRequest(call))
            }
        }
    }
    
    @objc func bannerHide(_ call: CAPPluginCall) {
        guard let id = call.getInt("id"),
              let banner = AMSAdBase.ads[id] as? AMSBanner
        else {
            call.reject("Invalid options")
            return
        }
        DispatchQueue.main.async {
            banner.hide(call)
        }
    }
    
    @objc func interstitialLoad(_ call: CAPPluginCall) {
        guard let id = call.getInt("id"),
              let adUnitId = call.getString("adUnitId")
        else {
            call.reject("Invalid options")
            return
        }
        var interstitial = AMSAdBase.ads[id] as? AMSInterstitial
        if interstitial == nil {
            interstitial = AMSInterstitial(id: id, adUnitId: adUnitId)
        }
        interstitial!.load(call, request: self.createGADRequest(call))
    }
    
    @objc func interstitialShow(_ call: CAPPluginCall) {
        guard let id = call.getInt("id"),
              let interstitial = AMSAdBase.ads[id] as? AMSInterstitial
        else {
            call.reject("Invalid options")
            return
        }
        interstitial.show(call)
    }
    
    @objc func rewardedLoad(_ call: CAPPluginCall) {
        guard let id = call.getInt("id"),
              let adUnitId = call.getString("adUnitId")
        else {
            call.reject("Invalid options")
            return
        }
        var rewarded = AMSAdBase.ads[id] as? AMSRewarded
        if rewarded == nil {
            rewarded = AMSRewarded(id: id, adUnitId: adUnitId)
        }
        rewarded!.load(call, request: self.createGADRequest(call))
    }
    
    @objc func rewardedShow(_ call: CAPPluginCall) {
        guard let id = call.getInt("id"),
              let rewarded = AMSAdBase.ads[id] as? AMSRewarded
        else {
            call.reject("Invalid options")
            return
        }
        rewarded.show(call)
    }
    
    func createGADRequest(_ call: CAPPluginCall) -> GADRequest {
        let request = GADRequest()
        if let testDevices = call.getArray("testDevices", String.self) {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDevices
        }
        if let childDirected = call.getBool("childDirected") {
            GADMobileAds.sharedInstance().requestConfiguration.tag(forChildDirectedTreatment: childDirected)
        }
        return request
    }
}
