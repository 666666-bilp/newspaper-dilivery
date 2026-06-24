<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*"%>
<% SysUser user = (SysUser) session.getAttribute("user"); if (user == null) { response.sendRedirect("index.jsp"); return; }
   Map<String, Object> monthlyStats = (Map<String, Object>) request.getAttribute("monthlyStats");
   List<Map<String, Object>> delivererPerf = (List<Map<String, Object>>) session.getAttribute("delivererPerf");
   List<Map<String, Object>> workload = (List<Map<String, Object>>) session.getAttribute("workload");
   List<Map<String, Object>> ranking = (List<Map<String, Object>>) session.getAttribute("ranking");
   List<Map<String, Object>> cumulative = (List<Map<String, Object>>) session.getAttribute("cumulative");
   Map<String, Object> bench = (Map<String, Object>) request.getAttribute("benchmark");
   List<Map<String, Object>> auditLogs = (List<Map<String, Object>>) session.getAttribute("auditLogs");
   String active = request.getParameter("action") != null ? request.getParameter("action") : ""; %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>管理统计</title>
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
  <div class="page-title">管理统计</div>

  <div class="card">
    <div class="card-title">统计功能</div>
    <div class="btn-group">
      <a class="btn btn-blue btn-sm" href="StatsServlet?action=monthly">月度统计(存储过程)</a>
      <a class="btn btn-blue btn-sm" href="StatsServlet?action=deliverer">发行员业绩(存储过程)</a>
      <a class="btn btn-sm" href="StatsServlet?action=workload">工作量视图</a>
      <a class="btn btn-blue btn-sm" href="StatsServlet?action=ranking">订阅排名(窗口函数)</a>
      <a class="btn btn-sm" href="StatsServlet?action=cumulative">累计订阅(窗口函数)</a>
      <a class="btn btn-sm" href="StatsServlet?action=index">索引性能对比</a>
      <a class="btn btn-sm" href="StatsServlet?action=audit">审计日志(触发器)</a>
    </div>
  </div>

  <% if (monthlyStats != null) { %>
  <div class="result-box">
    <h4>月度统计 <span>存储过程 sp_monthly_stats（2026年6月）</span></h4>
    <div class="stat-row">
      <div class="stat-box highlight"><div class="num"><%=monthlyStats.get("totalCustomers")%></div><div class="lbl">活跃客户数</div></div>
      <div class="stat-box highlight"><div class="num"><%=monthlyStats.get("totalSubscriptions")%></div><div class="lbl">有效订阅数</div></div>
      <div class="stat-box highlight"><div class="num"><%=monthlyStats.get("totalRevenue")%></div><div class="lbl">当月收入总额(元)</div></div>
    </div>
  </div>
  <% } %>

  <% if (delivererPerf != null) { %>
  <div class="result-box">
    <h4>发行员业绩 <span>存储过程 sp_deliverer_performance（2026年度）</span></h4>
    <div class="table-wrap"><table>
      <thead><tr><th>发行员</th><th>客户数</th><th>订阅数</th><th>收入总额(元)</th></tr></thead>
      <tbody><% for (Map<String, Object> row : delivererPerf) { %>
      <tr><td><%=row.get("delivererName")%></td><td><%=row.get("customerCount")%></td>
        <td><%=row.get("subscriptionCount")%></td><td><%=row.get("totalRevenue")%></td></tr>
      <% } %></tbody>
    </table></div>
  </div>
  <% } %>

  <% if (workload != null) { %>
  <div class="result-box">
    <h4>发行员工作量 <span>视图 v_deliverer_workload</span></h4>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>姓名</th><th>电话</th><th>状态</th><th>负责社区数</th><th>客户数</th><th>订阅数</th></tr></thead>
      <tbody><% for (Map<String, Object> row : workload) { %>
      <tr><td><%=row.get("delivererId")%></td><td><%=row.get("delivererName")%></td><td><%=row.get("phone")%></td>
        <td><span class="badge <%= "在职".equals(row.get("status")) ? "badge-active" : "badge-stop" %>"><%=row.get("status")%></span></td>
        <td><%=row.get("communityCount")%></td><td><%=row.get("customerCount")%></td><td><%=row.get("subscriptionCount")%></td></tr>
      <% } %></tbody>
    </table></div>
  </div>
  <% } %>

  <% if (ranking != null) { %>
  <div class="result-box">
    <h4>各社区报纸订阅排名 <span>窗口函数 RANK() OVER PARTITION BY</span></h4>
    <div class="table-wrap"><table>
      <thead><tr><th>社区</th><th>报纸</th><th>订阅数</th><th>排名</th></tr></thead>
      <tbody><% for (Map<String, Object> row : ranking) { %>
      <tr><td><%=row.get("communityName")%></td><td><%=row.get("newspaperName")%></td>
        <td><%=row.get("subCount")%></td><td><%=row.get("ranking")%></td></tr>
      <% } %></tbody>
    </table></div>
  </div>
  <% } %>

  <% if (cumulative != null) { %>
  <div class="result-box">
    <h4>报纸累计订阅量 <span>窗口函数 SUM() OVER PARTITION BY</span></h4>
    <div class="table-wrap"><table>
      <thead><tr><th>报纸</th><th>开始日期</th><th>累计数量</th></tr></thead>
      <tbody><% for (Map<String, Object> row : cumulative) { %>
      <tr><td><%=row.get("newspaperName")%></td><td><%=row.get("startDate")%></td><td><%=row.get("cumulativeQty")%></td></tr>
      <% } %></tbody>
    </table></div>
  </div>
  <% } %>

  <% if (bench != null) { %>
  <div class="result-box">
    <h4>索引性能对比</h4>
    <div class="stat-row">
      <div class="stat-box highlight"><div class="num"><%=bench.get("indexedQuery_ns")%></div><div class="lbl">索引查询耗时(ns)</div></div>
      <div class="stat-box"><div class="num"><%=bench.get("fullScanQuery_ns")%></div><div class="lbl">全表扫描耗时(ns)</div></div>
      <div class="stat-box highlight"><div class="num"><%=bench.get("ratio")%>x</div><div class="lbl">性能提升倍数</div></div>
    </div>
    <div style="font-size:12px;color:#999;margin-top:8px">EXPLAIN: <%=bench.get("explainResult")%></div>
  </div>
  <% } %>

  <% if (auditLogs != null) { %>
  <div class="result-box">
    <h4>审计日志 <span>触发器自动写入 audit_log</span></h4>
    <div class="table-wrap"><table>
      <thead><tr><th>ID</th><th>表名</th><th>操作</th><th>记录ID</th><th>旧数据</th><th>新数据</th><th>时间</th></tr></thead>
      <tbody><% for (Map<String, Object> row : auditLogs) { %>
      <tr><td><%=row.get("id")%></td><td><%=row.get("tableName")%></td><td><%=row.get("operation")%></td>
        <td><%=row.get("recordId")%></td>
        <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px"><%=row.get("oldData")%></td>
        <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px"><%=row.get("newData")%></td>
        <td style="font-size:12px"><%=row.get("operateTime")%></td></tr>
      <% } %></tbody>
    </table></div>
  </div>
  <% } %>

  <% if (active.isEmpty()) { %>
  <div class="nodata">请点击上方按钮查看各项统计</div>
  <% } %>
</div>
</body></html>
