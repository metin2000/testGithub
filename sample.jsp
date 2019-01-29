<%@ page import="java.util.Enumeration" %>
<%@ page import="com.nets.sso.common.AgentExceptionCode" %>
<%@ page import="com.nets.sso.common.Utility" %>
<%@ page import="com.nets.sso.common.enums.AuthStatus" %>
<%@ page import="com.nets.sso.agent.AuthUtil" %>
<%@ page import="com.nets.sso.agent.authcheck.AuthCheck" %>
<%@ page import="com.nets.sso.agent.configuration.SSOConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String logonUrl = "";		// 로그온 URL
String logoffUrl = "";		// 로그오프 URL
String returnUrl = "";		// 되돌아 올 URL
boolean isLogon = false;	// 로그온 여부
String logonId = "";		// 로그온 된 사용자 아이디
String userInfo = "";		// 로그온 된 사용자 추가정보 
String errorMsg = "";		// 에러 메시지
String idTagName = "";			// 아이디 태그명
String pwdTagName = "";			// 비밀번호 태그명
String credTagName = "";		// CredentialType 태그명
String returnUrlTagName = "";	// 되돌아갈 URL 태그명

try
{
	//인증객체생성 및 인증확인
	AuthCheck auth = new AuthCheck(request, response);
	//인증확인
	AuthStatus status = auth.checkLogon();
	
	//일반 설정값들
	try{
		//로그오프 URL
		/* logoffUrl = auth.getSsoProvider().getLogoffUrl() + "?" +
			auth.getSsoProvider().getRequestSSOSiteParam() + "=" + auth.getSsoSite().getSiteDNS() + "&" +
			auth.getSsoProvider().getReturnUrlTagName() + "=" + Utility.uRLEncode(auth.getThisUrl(), "UTF-8");
		
		//로그온 URL
		logonUrl = auth.getSsoProvider().getLogonUrl() + "?" +
				auth.getSsoProvider().getRequestSSOSiteParam() + "=" + auth.getSsoSite().getSiteDNS();
		 */
		 logoffUrl = auth.getSsoProvider().getLogoffUrl(request, auth.getSsoSite().getSiteDNS()) + "?" +
					auth.getSsoProvider().getRequestSSOSiteParam() + "=" + auth.getSsoSite().getSiteDNS() + "&" +
					auth.getSsoProvider().getReturnUrlTagName() + "=" + Utility.uRLEncode(auth.getThisUrl(), "UTF-8");
				
		//로그온 URL
		logonUrl = auth.getSsoProvider().getLogonUrl(request, auth.getSsoSite().getSiteDNS()) + "?" +
				auth.getSsoProvider().getRequestSSOSiteParam() + "=" + auth.getSsoSite().getSiteDNS();
				
				
		idTagName = auth.getSsoProvider().getIdTagName();
		pwdTagName = auth.getSsoProvider().getPwdTagName();
		credTagName = auth.getSsoProvider().getCredTypeTagName();
		returnUrlTagName = auth.getSsoProvider().getReturnUrlTagName();
	} catch (Exception e){
		out.print(e.toString());
	}
	
	//인증상태별 처리
	if(status == AuthStatus.SSOFirstAccess) {
		//최초 접속
		auth.trySSO();
	} else if(status == AuthStatus.SSOSuccess) {
		//인증성공
		returnUrl = request.getParameter(auth.getSsoProvider().getReturnUrlTagName());
		if (Utility.isNullOrEmpty(returnUrl) == false) {
		    response.sendRedirect(returnUrl);
		}
		isLogon = true;

		//하기 인증정보를 이용하여, 내부인증을 만들어 사용하세요.
		//로그인 아이디
		logonId = auth.getUserID();		
		
		//선입자를 끊고, 내가 인증 성공했을 경우, 선입자의 정보를 보여준다.
		if (Utility.isNullOrEmpty(auth.getDuplicationIP()) == false){
			String dupInfo = "(끊어진 사용자정보)\\nIP:" + auth.getDuplicationIP() + "\\nTime:" + auth.getDuplicationTime();
			errorMsg = "alertError('" + dupInfo + "', '');";
		}
		
		//사용자정보 조회 샘플
		//String somethingUserInfo = auth.getUserInfo("조회할이름");	//조회할 이름은 프로젝트 시, 정해지면 전달해드립니다.
	} else if(status == AuthStatus.SSOFail){
		//인증실패
		if (auth.getErrCode() != AgentExceptionCode.NoException){
			errorMsg = "alertError('" + auth.getErrCode().toString() + "', '');";
		}
		if (auth.getErrCode() == AgentExceptionCode.SessionDuplicationCheckedFirstPriority ||
				auth.getErrCode() == AgentExceptionCode.SessionDuplicationCheckedLastPriority){
			errorMsg = "alertError('중복로그인 정보 IP:" + auth.getDuplicationIP() + " TIME:" + auth.getDuplicationTime() + "', '');";
		}
		//로그오프를 해야하는 상황
		if (	auth.getErrCode() == AgentExceptionCode.SessionDuplicationCheckedLastPriority ||
				auth.getErrCode() == AgentExceptionCode.TokenIdleTimeout ||
				auth.getErrCode() == AgentExceptionCode.TokenExpired ||
				auth.getErrCode() == AgentExceptionCode.NoExistUserIDSessionValue){
			errorMsg += "OnLogoff();";
		}
		
		//리턴 URL 설정
		returnUrl = request.getParameter(auth.getSsoProvider().getReturnUrlTagName());
		if (Utility.isNullOrEmpty(returnUrl) == false) {
		    returnUrl = Utility.uRLEncode(returnUrl, "UTF-8");
		} else {
		    returnUrl = Utility.uRLEncode(auth.getThisUrl(), "UTF-8");
		}
		//SSO 실패 시 정책에 따라 자체 로그인 페이지로 이동 시키거나, SSO 인증을 위한 포탈 로그인 페이지로 이동
		//response.sendRedirect("이동할 URL");
	} else if(status == AuthStatus.SSOUnAvailable){
		//SSO장애
		//SSO 장애 시 정책에 따라 자체 로그인 페이지로 이동 시키거나, SSO 인증을 위한 포탈 로그인 페이지로 이동
		//response.sendRedirect("이동할 URL");
		errorMsg = "alertError('현재 통합인증 서비스가 불가합니다.', '');";
	} else if(status == AuthStatus.SSOAccessDenied){
		errorMsg = "alertError('인증은 되었지만, 현재 사이트에 접근 거부상태입니다', '');";
	}
%>
<!DOCTYPE html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title></title>
	<!-- 
	<script language="javascript" type="text/javascript" src="./scripts/cmactivex.js" ></script>
	-->
	<script language="javascript" type="text/javascript">
        //로그온
	    function OnLogon() {
	        if (document.forms["form1"].txtUserID.value == "") {
	            alert("사용자 ID를 입력하세요");
	            return;
	        }
	        if (document.forms["form1"].txtPwd.value == "") {
	            alert("사용자의 로그온 비밀번호를 입력하세요");
	            return;
	        }
			document.forms["form1"].action = "<%=logonUrl%>";
            document.forms["form1"].target = "_top";
            document.forms["form1"].submit();
	    }

        //에러 메시지
	    function alertError(msg, url) {
	        if (msg != "")
	            alert(msg);
	        if (url != "")
	            document.location.href = url;
	    }

	    //로그오프
	    function OnLogoff() {
	        document.location.href = "<%=logoffUrl%>";
	    }
	    
	    function OnInit(){
	    }
	</script>
</head>
<body onLoad="OnInit();">
    <form id="form1" method="post">
        <%if (isLogon == false) { %>
	    <table>
		    <tr>
			    <td colspan="2"> 로그온 사용자 정보 입력</td>
		    </tr>
		    <tr>
			    <td>사용자 ID : </td>
			    <td><input type="text" id="txtUserID" name="<%=idTagName%>" /></td>
		    </tr>
		    <tr>
			    <td>비밀번호 : </td>
			    <td><input type="password" id="txtPwd" name="<%=pwdTagName%>" /></td>
		    </tr>		
		    <tr>
			    <td colspan="2" align="center"><input type="button" value="로그온" onclick="OnLogon();" /></td>
		    </tr>
	    </table>		
	    <input type="hidden" id="credType" name="<%=credTagName%>" value="BASIC"/>
	    <input type="hidden" name="<%=returnUrlTagName%>" value="<%=returnUrl%>" />	
        <%} else {%>
			로그인 사용자 : <%=logonId %><br /><br />
        	사용자 정보 : <br /><%=userInfo%><br /><br />
       		<input type="button" value="로그오프" onclick="OnLogoff();" />
        <%} %>
    </form>
    
<script language="javascript">
<%=errorMsg%>
</script>
</body>
</html>

<%
}catch(Exception ex){
	ex.printStackTrace();
	out.print(ex.toString());
}
%>



