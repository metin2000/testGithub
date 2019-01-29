<%@ page import="java.util.Enumeration" %>
<%@ page import="com.nets.sso.common.AgentExceptionCode" %>
<%@ page import="com.nets.sso.common.Utility" %>
<%@ page import="com.nets.sso.common.enums.AuthStatus" %>
<%@ page import="com.nets.sso.agent.AuthUtil" %>
<%@ page import="com.nets.sso.agent.authcheck.AuthCheck" %>
<%@ page import="com.nets.sso.agent.configuration.SSOConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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
