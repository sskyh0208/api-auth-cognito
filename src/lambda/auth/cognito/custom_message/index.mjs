const MESSAGE_TEMPLATE =`
<html>
<head></head>
<body>
  <p>サインアップを完了するには、以下の確認コードを入力してください。</p>
  <p>確認コード：{{####}}</p>
  <p>
    ------------------------------<br/>
    確認コードの有効期限は<br/>
    {{expire}}<br/>
    です。<br/>
    ------------------------------
  </p>
</body>
</html>
`

const SUBJECT = '仮登録完了のお知らせ';

export const handler = async (event) => {
  const utcNow = new Date();
  const jstNow = new Date(utcNow.setHours(utcNow.getHours() + 9));

  const limit = new Date(jstNow.setDate(jstNow.getDate() + 1));

  const ymd = limit.toLocaleDateString('sv-SE');
  const hms = limit.toLocaleTimeString('ja-JP', {hour12: false});

  const expire = `${ymd} ${hms}`;
  console.log('Expire:', expire);

  const emailMessage = MESSAGE_TEMPLATE
    .replace('{{####}}', event.request.codeParameter)
    .replace('{{expire}}', expire);
  
  event.response.emailMessage = emailMessage;
  event.response.emailSubject = SUBJECT;

  return event;
};