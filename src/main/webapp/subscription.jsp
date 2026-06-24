<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; }
   List<Subscription> subscriptions = (List<Subscription>) session.getAttribute("subscriptions");
   List<Customer> customers = (List<Customer>) session.getAttribute("customers");
   List<Newspaper> newspapers = (List<Newspaper>) session.getAttribute("newspapers");
   if (subscriptions == null || customers == null || newspapers == null) { response.sendRedirect("SubscriptionServlet?action=list"); return; }
   String txnResult = (String) session.getAttribute("txnResult"); %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>订阅管理</title>
<link rel="stylesheet" href="style.css?v=2"></head>
<body>
<div class="topbar">
  <div class="topbar-brand">报纸投递管理系统</div>
  <div class="topbar-nav">
    <a href="main.jsp">返回主页</a>
    <span class="topbar-user"><%= user.getUsername() %></span>
  </div>
</div>
<div class="page">
  <div class="page-title">订阅管理</div>

  <div class="card">
    <div class="card-title">新增订阅</div>
    <form method="post" action="SubscriptionServlet">
      <div class="form-line">
        <select name="customerId" required>
          <option value="">选择客户</option>
          <% for(Customer c : customers) { %><option value="<%=c.getId()%>"><%=c.getName()%>（<%=c.getCommunityName()%>）</option><% } %>
        </select>
        <select name="newspaperId" required>
          <option value="">选择报纸</option>
          <% for(Newspaper n : newspapers) { %><option value="<%=n.getId()%>"><%=n.getName()%> <%=String.format("%.2f", n.getPrice())%>元</option><% } %>
        </select>
        <input type="number" name="quantity" placeholder="数量" min="1" value="1" required style="width:70px">
        <input type="date" name="startDate" required>
        <button type="submit" class="btn btn-blue">确认订阅</button>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-title">事务演示（退订+新建）</div>
    <% if (txnResult != null) { %>
    <div class="<%=txnResult.startsWith("SUCCESS") ? "msg-ok" : "msg-err" %>">
      执行结果: <%= txnResult %>
    </div>
    <% session.removeAttribute("txnResult"); } %>
    <form method="get" action="SubscriptionServlet">
      <input type="hidden" name="action" value="txn">
      <div class="form-line" style="margin-bottom:8px">
        <select name="oldSubId" required>
          <option value="">1.选择要退订的订阅</option>
          <% for(Subscription s : subscriptions) { if("订阅中".equals(s.getStatus())) { %>
          <option value="<%=s.getId()%>">#<%=s.getId()%> <%=s.getCustomerName()%> - <%=s.getNewspaperName()%></option>
          <% }} %>
        </select>
      </div>
      <div class="form-line">
        <select name="customerId" required>
          <option value="">2.新客户</option>
          <% for(Customer c : customers) { %><option value="<%=c.getId()%>"><%=c.getName()%></option><% } %>
        </select>
        <select name="newspaperId" required>
          <option value="">3.新报纸</option>
          <% for(Newspaper n : newspapers) { %><option value="<%=n.getId()%>"><%=n.getName()%></option><% } %>
        </select>
        <input type="number" name="quantity" placeholder="数量" min="1" value="1" required style="width:70px">
        <input type="date" name="startDate" required>
        <button type="submit" class="btn btn-green">执行事务</button>
      </div>
    </form>
  </div>

  <div class="card">
    <div class="card-title">订阅列表 <span class="count">共 <%=subscriptions.size()%> 条</span></div>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>客户</th><th>社区</th><th>报纸</th><th>数量</th><th>金额(元)</th><th>开始</th><th>结束</th><th>状态</th><th>操作</th></tr></thead>
      <tbody>
      <% for (Subscription s : subscriptions) { %>
      <tr><td><%=s.getId()%></td><td><%=s.getCustomerName()%></td><td><%=s.getCommunityName()%></td>
        <td><%=s.getNewspaperName()%></td><td><%=s.getQuantity()%></td>
        <td><%=String.format("%.2f", s.getTotalAmount())%></td>
        <td><%=s.getStartDate()%></td><td><%=s.getEndDate() != null ? s.getEndDate() : "-"%></td>
        <td><span class="badge <%= "订阅中".equals(s.getStatus()) ? "badge-active" : "badge-stop" %>"><%=s.getStatus()%></span></td>
        <td><% if("订阅中".equals(s.getStatus())) { %>
          <a class="btn btn-red btn-sm" href="SubscriptionServlet?action=cancel&id=<%=s.getId()%>" onclick="return confirm('确定退订？')">退订</a>
        <% } %></td></tr>
      <% } %>
      </tbody>
    </table></div>
  </div>
</div>
</body></html>
