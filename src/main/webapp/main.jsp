<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="model.SysUser"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; } %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>报纸投递管理系统</title>
<link rel="stylesheet" href="style.css?v=2"></head>
<body>
<div class="topbar">
  <div class="topbar-brand">报纸投递管理系统</div>
  <div class="topbar-nav">
    欢迎，<span class="topbar-user"><%= user.getUsername() %></span>
    <a href="LoginServlet">退出</a>
  </div>
</div>
<div class="page">
  <div class="page-title">功能导航</div>
  <div class="home-grid">
    <a class="home-item" href="customer.jsp"><h3>客户管理</h3><p>客户信息的查询、添加、修改和删除</p></a>
    <a class="home-item" href="deliverer.jsp"><h3>发行员管理</h3><p>发行员信息的查询和维护</p></a>
    <a class="home-item" href="newspaper.jsp"><h3>报纸管理</h3><p>报纸信息维护和查询</p></a>
    <a class="home-item" href="subscription.jsp"><h3>订阅管理</h3><p>报纸订购和退订</p></a>
    <a class="home-item" href="stats.jsp"><h3>管理统计</h3><p>发行员工作量、订阅统计、数据库技术演示</p></a>
    <a class="home-item" href="UserManageServlet?action=list"><h3>用户管理</h3><p>系统用户的添加、删除和密码修改</p></a>
  </div>
</div>
</body></html>
