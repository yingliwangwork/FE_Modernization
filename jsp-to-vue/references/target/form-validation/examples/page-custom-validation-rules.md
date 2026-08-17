# 頁面自訂驗證規則使用範例

```js
    import { string, object } from 'yup'

    // 定義驗證規則(單欄驗證)：邀請碼須符合指定字串
    const validateInviteCode = (errMsg = '請輸入正確的邀請碼') => ({
        name: 'validateInviteCode', message: errMsg, test: function (value) {
            return !!value && value === "INVITE2024"
        }
    })

    // 定義驗證規則(跨欄驗證)：推薦碼不可與邀請碼相同
    const validateReferralNotSame = (targetId, errMsg = '推薦碼不可與邀請碼相同:${value}') => ({
        name: 'validateReferralNotSame', message: errMsg, test: function (value, context) {
            // 取得表單其他欄位值
            const targetVal = context.parent?.[targetId];
            return value !== targetVal
        }
    })

    const validationSchema = object({
        // 使用 .test() 綁定驗證器
        inviteCode: string().test(validateInviteCode()),
        referralCode: string().test(validateReferralNotSame('inviteCode')),
    })
```