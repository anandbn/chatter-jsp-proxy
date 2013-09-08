<%@ page import="httputils.*"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.nio.CharBuffer" %>
<%@ page import="java.nio.ByteBuffer" %>
<%
	HttpRequest req = new HttpRequest();
	if(request.getHeader("Authorization")!=null){
		System.out.println(String.format("Method: %s,Proxying %s",
										 request.getMethod(),
										 request.getParameter("path")));
		req =   req.method(request.getMethod())
				   .header("Authorization", request.getHeader("Authorization"))
				   .header("Accept", "application/json")
				   .header("Content-Type", "application/json")
				   .url("https://"+request.getParameter("path"));
		if(request.getMethod().equalsIgnoreCase("POST")){
			req = req.content(Http.readResponse(request.getInputStream()));
		}
		if(request.getMethod().equalsIgnoreCase("PATCH")){
			req = req.content(Http.readResponse(request.getInputStream()));
		}
		HttpResponse theResp= Http.send(req);
		response.addHeader("Content-Type",theResp.getResponseContentType());
		out.print(theResp.getString());
	}else{
		out.println("No OAuth header found");
	}
%>
