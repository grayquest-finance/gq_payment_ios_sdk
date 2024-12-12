# GQPaymentIOSSDK

[![CI Status](https://img.shields.io/travis/1410avi/GQPaymentIOSSDK.svg?style=flat)](https://travis-ci.org/1410avi/GQPaymentIOSSDK)
[![Version](https://img.shields.io/cocoapods/v/GQPaymentIOSSDK.svg?style=flat)](https://cocoapods.org/pods/GQPaymentIOSSDK)
[![License](https://img.shields.io/cocoapods/l/GQPaymentIOSSDK.svg?style=flat)](https://cocoapods.org/pods/GQPaymentIOSSDK)
[![Platform](https://img.shields.io/cocoapods/p/GQPaymentIOSSDK.svg?style=flat)](https://cocoapods.org/pods/GQPaymentIOSSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This SDK Supports iOS Version 13.0 and above.

## Installation

GQPaymentIOSSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GQPaymentIOSSDK', '~> 1.0.1'
```


## Package Whitelisting
The newest versions of our GQPaymentIOSSDK(1.0.1 and newer) will require your app package/bundle to be whitelisted in system to use the SDK Checkout. Whitelisting request can be made from GrayQuest Team


## Initialising

Import the SDK on your viewcontroller, where you want to present the payment screen.

```ruby
import GQPaymentIOSSDK
```


Initialise the GQPaymentSDK class.

```ruby
let gqPaymentSDK = GQPaymentSDK()

gqPaymentSDK.modalPresentationStyle = .overFullScreen
gqPaymentSDK.modalTransitionStyle = .crossDissolve

gqPaymentSDK.delegate = self
gqPaymentSDK.clientJSONObject = <ClientJSONObject>
gqPaymentSDK.prefillJSONObject = <PrefillJSONObject>

DispatchQueue.main.async {
    self.present(gqPaymentSDK, animated: true)
}
```


## Add the following code for Delegates/ Callbacks:

Confirm your Viewcontroller to the GQPaymentDelegate protocol:

```ruby
extension ViewController: GQPaymentDelegate {
```
    
    
Use these methods to receive Success, Failure and Cancel response.

```ruby
func gqSuccessResponse(data: [String : Any]?) {
    print("Success callback received with data: \(data)")
}

func gqFailureResponse(data: [String : Any]?) {
    print("Failure callback received with data: \(data)")
}

func gqCancelResponse(data: [String : Any]?) {
    print("Cancel callback received with data: \(data)")
}
```
    
    
## Options

Available options that can be set while initiating the sdk.

    
### Environment

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | env | string | **Values**: `stage` <br> **Possible Scenarios:** <br> 1. If the value is `stage` then SDK will connect with Testing environment <br> 2. If the value is `live` then SDK will connect with the Live/Production environment | Yes |
 

### Authentication

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | client_id | string | Authentication credential | Yes |
| 2 | client_secret_key | string | Authentication credential | Yes |
| 3 | gq_api_key | string | Authentication credential | Yes |


### Unique Identifiers
     
| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | student_id  | string | Unique id of the student used to create the gq application with reference to customer mobile number. | Yes |
| 2 | customer_number | string | Used to create a customer in the GrayQuest System | Yes |
| 3 | reference_id | string | Unique ERP Order ID | No |


### Payment Page

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | slug | string    | Slug to activate the configuration of a specific payment page. (provided by GQ) | No |


### Fee Headers

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | fee_headers | string | Custom fee headers to be configured in GQ. <br> **Example:** <br> `fee_headers: { "fee_type_1": AMOUNT 1, "fee_type_2": AMOUNT 2,  .  .  . "fee_type_n": AMOUNT n }` | No |


### Additional Options

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | student_first_name | string | First name of student <br> `Note: First name should contain only alphabets and space.` | No |
| 2 | student_middle_name | string | Middle name of student <br> `Note: Middle name should contain only alphabets and space.` | No |
| 3 | student_last_name | string | Last name of student <br> `Note: Last name should contain only alphabets and space.` | No |
| 4 | student_type | string | **Type of Student  Values:**  <br> `EXISTING` <br> `NEW` | No |


### Applicant Details

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | customer_first_name | string | First name of customer <br> `Note: First name should contain only alphabets and space.` | No |
| 2 | customer_middle_name | string | Middle name of customer <br> `Note: Middle name should contain only alphabets and space.` | No |
| 3 | customer_last_name | string | Last name of customer <br> `Note: Last name should contain only alphabets and space.` | No |
| 4 | customer_dob | string | Date of birth of customer (yyyy-mm-dd) | No |
| 5 | customer_gender | string | Gender of customer<br> **Values:** <br> `MALE` <br>`FEMALE` | No |
| 6 | customer_email | string | Email address of customer | No |
| 7 | customer_marital_status | string | Marital Status of Customer <br> **Values:** <br>`MARRIED` <br>`DIVORCED` <br>`OTHERS` | No |
| 8 | pan_number | string | Customer's PAN card number | No |


### Employment Details - Salaried

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | income_type | string | Type of income <br> **Value:** <br> `SALARIED` | No |
| 2 | employer_name | string | Name of employer | No |
|3 | work_experience | string | Years of experience <br> **Values:** <br> `LESS THAN 2 YEARS` <br> `2-5 YEARS` <br> `5-10 YEARS` <br> `GREATER THAN 10 YEARS` | No |
| 4 | net_monthly_salary | string | Monthly salary <br> `Note: Salary can only contain numeric values` | No |


### Employment Details - Self Employed

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | income_type | string | Type of income <br> **Value:** <br> `SELF EMPLOYED` | No |
| 2 | business_name | string | Name of the business | No |
| 3 | business_annual_income | string | Total annual income of business <br> `Note: Annual income can only contain numeric values.` | No |
| 4 | business_description | string | Business Details | No |
| 5 | years_of_current_business | string | Total number of years since business has been established <br> `Note: Current business years can only contain numeric values.` | No |
| 6 | notes  | json | Notes object where you can provide any key-value pairs for your internal reference | No |


### Customizations

Below options can be used for customizations.

| Sr. No. | Option | Data Type | Description | Mandatory |
|--|--|--|--|--|
| 1 | logo_url | string | To add a custom institute logo which is shown on the popup/sdk. <br> `Ideal Image Size: 100 X 100 px` | No |
| 2 | theme_color | string | Add/Override custom theme color of the SDK/Popup <br> `Note: 6 digit hex color code is required. ex.#2C3E50` | No |


`NOTE: If data for a specific field is not available then you should not send the variable or key.`


## Complete Code:

```ruby
import GQPaymentIOSSDK

class ViewController: UIViewController, GQPaymentDelegate {

    func gqSuccessResponse(data: [String : Any]?) {
        print("Success callback received with data: \(data)")
    }
    
    func gqFailureResponse(data: [String : Any]?) {
        print("Failure callback received with data: \(data)")
    }
    
    func gqCancelResponse(data: [String : Any]?) {
        print("Cancel callback received with data: \(data)")
    }
    
    var clientJSONObject: [String: Any]?
    var prefillJSONObject: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let auth: [String: Any] = [
          "client_id": "<client_id>",
          "client_secret_key": "<client_secret_key>",
          "gq_api_key": "<gq_api_key>"
        ]

        let ppConfig: [String: Any] = [
          "slug": "<slug>"
        ]

        let feeHeaders: [String: Any] = [
          "fee_type_1": <AMOUNT 1>,
          "fee_type_2": <AMOUNT 2>,
          .
          .
          .
          "fee_type_n": <AMOUNT n>
        ]

        clientJSONObject = [
          "auth": auth,
          "student_id": "<student_id>",
          "env": "<env>",
          "customer_number": "<customer_number>",
          "pp_config": ppConfig,
          "fee_headers": feeHeaders
        ]

        let student_details: [String: Any] = [
          "student_first_name": "<student_first_name>",
          "student_last_name": "<student_last_name>",
          "student_type": "<student_type>"
        ]

        let customer_details: [String: Any] = [
          "customer_first_name": "<customer_first_name>",
          "customer_last_name": "<customer_last_name>",
          "customer_dob": "<customer_dob>",
          "customer_gender": "<customer_gender>",
          "customer_email": "<customer_email>",
          "customer_marital_status": "<customer_marital_status>"
        ]

        let kyc_details: [String: Any] = [
          "pan_number": "<pan_number>"
        ]

        let employment_details: [String: Any] = [
          "income_type": "<income_type>",
          "employer_name": "<employer_name>",
          "work_experience": "<work_experience>",
          "net_monthly_salary": "<net_monthly_salary>",
          "business_name": "<business_name>",
          "business_turnover": "<business_turnover>",
          "business_annual_income": "<business_annual_income>",
          "business_category": "<business_category>",
          "business_type": "<business_type>",
          "business_description": "<business_description>",
          "business_employee_count": "<business_employee_count>",
          "years_of_current_business": "<years_of_current_business>",
          "same_as_residence_address": "<same_as_residence_address>",
          "addr_line_1": "<addr_line_1>",
          "addr_line_2": "<addr_line_2>",
          "city": "<city>",
          "state": "<state>"
        ]
        
        let customization: [String: Any] = [
          "fee_helper_text": "<fee_helper_text>",
          "logo_url": "<logo_url>",
          "theme_color": "<theme_color>"
        ]

        let notes: [String: Any] = [
          "key": "<value>"
        ]

        prefillJSONObject = [
          "student_details": student_details,
          "customer_details": customer_details,
          "kyc_details": kyc_details,
          "employment_details": employment_details,
          "customization": customization
          "notes": notes
        ]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let gqPaymentSDK = GQPaymentSDK()
        
        gqPaymentSDK.modalPresentationStyle = .overFullScreen
        gqPaymentSDK.modalTransitionStyle = .crossDissolve
        
        gqPaymentSDK.delegate = self
        gqPaymentSDK.clientJSONObject = clientJSONObject
        gqPaymentSDK.prefillJSONObject = prefillJSONObject
        DispatchQueue.main.async {
            self.present(gqPaymentSDK, animated: true)
        }
    }
    
}
```
    
    
## Author

1410avi, avinash.soni@grayquest.com

## License

GQPaymentIOSSDK is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
