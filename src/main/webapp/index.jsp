<%@ page language="java" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>报纸投递管理系统</title>
<link rel="stylesheet" href="style.css?v=2"></head>
<body class="login-body">
<div class="login-wrap">
<h2>报纸投递管理系统</h2>
<form method="post" action="LoginServlet">
<label>用户名</label>
<input type="text" name="username" placeholder="请输入用户名" required autofocus>
<label>密码</label>
<input type="password" name="password" placeholder="请输入密码" required>
<button type="submit">登 录</button>
</form>
<p class="hint">默认账号: admin / 123456</p>
</div>
</body></html>
