//
//  ServiceDataViewController.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

class ServiceDataViewController: UIViewController {
    
    @IBOutlet private var authInfoLabel: UILabel!
    @IBOutlet private var authWithServiceButton: UIButton!
    @IBOutlet private var authWithoutServiceButton: UIButton!
    
    @IBOutlet private var servicesLabel: UILabel!
    @IBOutlet private var addServiceButton: UIButton!
    @IBOutlet private var refreshDataButton: UIButton!
    @IBOutlet private var deleteUserButton: UIButton!
    
    @IBOutlet private var loggerTextView: UITextView!
    
    private var digiMe: DigiMe!
    private var logger: Logger!
    private var currentContract: Contract!
    
    private var accounts = [Account]()
    private var selectServiceCompletion: ((Service?) -> Void)?
    
    private enum Contracts {
        // This contract allows SDK user to read user's social,
        // financial and music data from the past 3 months.
        static let finSocMus = Contract(name: "Social, Music & Financial", identifier: "DGLxRJiTjKZJvvtDB6timfzw4DHiQwek", privateKey: """
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAiM7QAmRiK322Npd0loxxxhIuLZVbc+2JRt7GRgTBG1RoaQ8e
0DrOVI8xz7XHe6PduoVs+TqZwYPEngGLq1f4+gZuyqeMOpUC5YFGs8QYro9UwJmG
bKf6ez4uYCMIFroKxRmnP0GrsDEjrvYksmJdQoq3Hg4wT6ZoQeQ2iNy4Z8Y5Jpb8
9Yuh1kb4vh5y4RJPmWui6yoOclovPOvFal2VmaDz1mgUbOfT5tbkEyKavm3u95d+
+hcEl9cOrke0G/aq9H2TSWTDqoqq0BKIDYRmGjhzsIB/xHPEqLkuTy3Or5AqRMSu
70U0R02bF7YjgZ4Ixka3AbE9ZBel2PtmeS6h0QIDAQABAoIBABn7pXf+1sJJ0vSV
WVhKfkVPKKQRrNfcsmjaYK/lsUNeiaICdCi6MnvO4nf/n051NeR5+NNw9MjTHOGh
i4RUZf4egKZOogxyRqWOIv57bPCiWkdmISi70o/bpHUv0hZ26Rq8H46dC12gR5Ww
PBIBKpM7w0GbEkPeaAizrkPaH8/dhXb2Hzkj5X5xrxsq1O8pI/VpSvGDXuJYF8U1
LOV8d1xJJLS0eHJvfe/5GSIIqEeJsXAzgs7yVOU9YhV0tgLh//lz4jj7xsvfpVOF
ScefjsgusJecB60+19OBTls/mfADVxG85wXkuCbO0QDPE9ZR2FLyzOcOLMLizWmF
o617A80CgYEA8q6VfWr3GMQfENW0PAhP+odqNglc8B4/N40ExzX54p0xFz/qtVZw
7jnPwo+EF5CRz4IwRWw/h10JqrJb85j77oLT/ADRy8+0Zhgp+bo278zxSTodiBhv
xoa2J3GeiLoed3QCwfp+MEE/gnRclK6SZs3skhBO/0cjvfRD4ulhR9MCgYEAkFDQ
Md/JpcFStyqpw8s+syIlSYfvyV8MLWcIqMvG9auJKNVmtAhA9lipEy0Tot6DG8d8
7EtTFKzCa+0jJoNEY+STCRBibyGZgkCGEvHOnab7gPZCu5bnJ/BW3JFhLagAveEG
2epF2k1xyhQ91zE1aXnsRwFSXlc1QyS4jwknrUsCgYEAw57vabW7kP8me4+IRYv9
zFkzyHMrs3LuSn0mCN79mypS1Ab1z07qoV2Al7jQJZ6nqrmq54smepsIm8xCSs5a
5hwXfN+8PaokJNf9ngv5FLwDE6ABBh+Mml8kng78WAKPZILjZjHhXkx6QVJC/qbp
5GzB8curoiNaMFiiEFtHy3kCgYBmvADZ4FOuWedGWWqs5TznTMF6jPjYQ39putVh
RF+Id+qWVQRd2RpVxFvoOMinwvtWhTabCCxGpY1qQ1AolH3VFtzNMQrBzgt3u/M1
/Ul21W5pKeXroMtBlUhgkGW7mMOeaFj2PF4pv8PndW1oibFaOt9G1NwMKMzT1YpE
2OGT7QKBgB7eLeoem83FmRsdSHX5LqcQL2K/9YRED1OuCCbIIzlRrgXtWFWp3fFv
ojU7Mub4TWjHLClgifeyJ2rc35gRn7+QWcYgeUjEdncdiAgB914eP81JKeRzufe1
wpFeXUa88GKAnNy0Rng81omO6kRDW5Bz8ppQbvnjKnUJgu2seSR0
-----END RSA PRIVATE KEY-----
"""
        )
        
        // This contract allows SDK user to read user's medical
        // and fitness data from the past 3 months.
        static let fitHealth = Contract(name: "Health & Fitness", identifier: "iB6siPdN5j6yVvv0PYMLiSBqSiq8SAG4", privateKey: """
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEAiKbIKoTmPrFWiOaGuuUjJXSBUWj/LOC3fhzSF/M7O0C9GP9+
            TGooxS98o6zLPHHkbRDktT1nh5cEagS6vjeCrcrcwlWPGmMMRb1LVE1fIurnzzSb
            /VTogHsKM6Rltzkdd2AFM39q3ALdYi7MiVRlyVWwcr8z8HlM/1XSuX8e26HDt3so
            oITZ3cZbw/P3cgSlDrk6k0knTB7l1v3tb/ulp9wp6k27DK1pbEriWtLeWGvoB8UC
            I/eC9O8clw/nUvMETf2ne18BVBTjQs37NDiNynAyLtDzJuCrsO0KP4LarXn8zoya
            R7Hl7Y+zjQYitupjEupSrlPcshu+UgiTXXBbvQIDAQABAoIBACqGlKY+w5RhBcgG
            zYjeBAkE77WRElA6AoB5oZwYcqdm5zIfWIOZSeTLeWNKQ9kkrGyQpEwOtuhIQ/Rm
            UmMdzUoeZoMHs0gH6OrPFOFATsoEBm3CNoUo5k4NfEhD8e+KE7Rxqkyza2LadWC3
            palbHW4Bf67F9/jvFtojMDfP6p94h1yt0Bi4AMa9Ba0mxN16tRQYaOpMxJK2Eh3l
            6+4dlD2/78T2oRlRkaLN+KO6zr5u2l5j3fS0PnVA9HtkY5aPZVsRrW4q5sARfQmP
            fiIKpNXpSKcZr7NaH5zC95gL3Jd40l2E2oxpXrm8BAQHo5sJViWOK+OuNCnsvD9Q
            io4rtxUCgYEA+/OWoDgnIYh2GnKeDcJN0/GHcjeon0V/Yv6VnfdC66OUjF++rqcl
            zU0A60apPRNFzw9Cjhl9T4GC+2Y0jskzlen5Q7slYvdAu3k0CT6qc8ZKzNBAG09I
            0Oxu+sQ07yxQT3zP8+C2tD9IdmVADdMPNL8r/ny1QlAEKzy+PKit5LMCgYEAitjn
            GKZSbfPpaR5EoN5ZvG4/8Pe0LU5MzrkgjWDHQeoEvm3ScJnDXva2gpYlgcYdNpDG
            rqB/W5yADZrvqv5RvU/7zDlS0wGo7Ld7Za7NPX52+j63hMWbtWBU/E1IXSjahoql
            NuLYqVnkzvj1cfsAwnfjt0tjSKek/zGZF5kHVc8CgYEA1UrE1ERVVD0LBp7LkQhS
            DL/nE1ltJdCW4/50OPOPMp8b7a5MZdzY0rGCuqrqMOs06PKZPGT1wa35bcx7Z/mK
            8znNLHqtTtfUdCFKXR0w/av7vOH7s2LuWPgfh6k8ytFv96rI/UPaSENem+RhUpK/
            x76jhuCaLlZBAT1+Kyn9dKMCgYBJaxQXxqrDlTwQ535miextZObOpkxRwJuAnAeI
            emoignnrr+qcu9HA/zfWqUo/6uA7oCZO5HMzn/deOlUM19mk/wwoGw+en7wRH5xS
            UjIYmCyVemBUBqGlMMD/gGYJTLbweZOPCDiEpBIHF0HB+XWXXwm8PFLNckge4L0Q
            60wjpQKBgFeMyC/mTX0OwiKz24MsaAr/NJN6beKKb3tntuz3VsJ/b774klaSHWzK
            Sgg3BZfcey+FLXWYiONXgoxXEZ9Y+Onsg8ZsQrfY/rUBdIzi0w80y1mijBDamoa6
            unJYbtDxQhgcarKzuDOfr6lIzdxQFeviTf8+SaCfTAIgEZOX9x2b
            -----END RSA PRIVATE KEY-----
            """
        )
    }
    
    private var authorizedDate: Date? {
        get {
            guard let timestamp = UserDefaults.standard.object(forKey: "\(currentContract.identifier).authorizedDate") as? Double else {
                return nil
            }
            
            return Date(timeIntervalSince1970: timestamp)
        }
        
        set {
            UserDefaults.standard.setValue(newValue?.timeIntervalSince1970, forKey: "\(currentContract.identifier).authorizedDate")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Service Data Example"
        
        logger = Logger(textView: loggerTextView)
        logger.log(message: "This is where log messages appear.")
        
        currentContract = Contracts.finSocMus
        
        do {
            let config = try Configuration(appId: AppInfo.appId, contractId: currentContract.identifier, privateKey: currentContract.privateKey)
            digiMe = DigiMe(configuration: config)
            
            updateUI()
        }
        catch {
            logger.log(message: "Unable to configure digi.me SDK: \(error)")
        }
    }
    
    @IBAction private func authorizeWithService() {
        selectService { service in
            guard let service = service else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Please select try again and select a service", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            self.authorizeAndReadData(service: service)
        }
    }
    
    @IBAction private func authorizeWithoutService() {
        authorizeAndReadData(service: nil)
    }
    
    @IBAction private func addService() {
        selectService { service in
            guard let service = service else {
                return
            }
            
            self.digiMe.addService(identifier: service.identifier) { error in
                if let error = error {
                    self.logger.log(message: "Adding \(service.name) failed: " + error.localizedDescription)
                    return
                }
                
                self.getAccounts()
                self.getServiceData()
            }
        }
    }
    
    @IBAction private func refreshData() {
        authorizeAndReadData(service: nil)
    }
    
    @IBAction private func deleteUser() {
        digiMe.deleteUser { error in
            if let error = error {
                self.logger.log(message: "Deleting user failed: " + error.localizedDescription)
                return
            }
            
            self.authorizedDate = nil
            self.accounts = []
            self.logger.reset()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateUI()
            }
            
            return
        }
        
        if digiMe.isConnected {
            
            if let date = authorizedDate {
                authInfoLabel.text = "Authorized on \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))"
            }
            else {
                authInfoLabel.text = "Authorized"
            }
            
            authWithServiceButton.isHidden = true
            authWithoutServiceButton.isHidden = true
            servicesLabel.isHidden = false
            addServiceButton.isHidden = false
            deleteUserButton.isHidden = false
            
            var servicesText = "Services:"
            if accounts.isEmpty {
                servicesText += "\n\tNone"
                refreshDataButton.isHidden = true
            }
            else {
                accounts.forEach { account in
                    servicesText += "\n\(account.service.name) - \(account.name)"
                }
                refreshDataButton.isHidden = false
            }
            
            servicesLabel.text = servicesText
        }
        else {
            authInfoLabel.text = "You haven't authorized this contract yet."
            authWithoutServiceButton.isHidden = false
            authWithServiceButton.isHidden = false
            servicesLabel.isHidden = true
            addServiceButton.isHidden = true
            refreshDataButton.isHidden = true
            deleteUserButton.isHidden = true
        }
    }
    
    private func authorizeAndReadData(service: Service?) {
        digiMe.authorize(serviceId: service?.identifier, readOptions: nil) { error in
            if let error = error {
                self.logger.log(message: "Authorization failed: \(error)")
                return
            }
            
            if self.authorizedDate == nil {
                self.authorizedDate = Date()
            }
            
            self.updateUI()
            self.getAccounts()
            self.getServiceData()
        }
    }
    
    private func selectService(completion: @escaping ((Service?) -> Void)) {
        digiMe.availableServices(scope: .thisContractOnly) { result in
            switch result {
            case .success(let servicesInfo):
                self.selectServiceCompletion = completion
                DispatchQueue.main.async {
                    let vc = ServicePickerViewController(services: servicesInfo.services)
                    vc.delegate = self
                    let nc = UINavigationController(rootViewController: vc)
                    self.present(nc, animated: true, completion: nil)
                }
                
                return
            case .failure(let error):
                self.logger.log(message: "Unable to retrieve services: \(error)")
            }
        }
    }
    
    private func getAccounts() {
        digiMe.readAccounts { result in
            switch result {
            case .success(let accountsInfo):
                self.accounts = accountsInfo.accounts
                self.updateUI()
            case .failure(let error):
                self.logger.log(message: "Error retrieving accounts: \(error)")
            }
        }
    }

    private func getServiceData() {
        digiMe.readFiles(readOptions: nil) { result in
            switch result {
            case .success(let fileContainer):
                var message = "Downloaded file \(fileContainer.identifier)"
                switch fileContainer.metadata {
                case .mapped(let metadata):
                    message += "\n\tService group: \(metadata.serviceGroup)"
                    message += "\n\tService name: \(metadata.serviceName)"
                    message += "\n\tObject type: \(metadata.objectType)"
                    message += "\n\tItem count: \(metadata.objectCount)"
                default:
                    message += "\n\tUnexpected metadata"
                }
                
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading file: \(error)")
            }
        } completion: { result in
            switch result {
            case .success(let fileList):
                var message = "Finished reading files:"
                fileList.files.forEach { message += "\n\t\($0.name)" }
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading files: \(error)")
            }
        }
    }
}

extension ServiceDataViewController: ServicePickerDelegate {
    func didSelectService(_ service: Service?) {
        selectServiceCompletion?(service)
        selectServiceCompletion = nil
    }
}
