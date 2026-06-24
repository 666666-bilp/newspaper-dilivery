package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.SysUser;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        DB db = new DB();
        SysUser user = db.login(username, password);
        if (user != null) {
            req.getSession().setAttribute("user", user);
            resp.sendRedirect("main.jsp");
        } else {
            resp.getWriter().println("<html><body><h3>登录失败</h3><a href='index.jsp'>返回</a></body></html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getSession().invalidate();
        resp.sendRedirect("index.jsp");
    }
}
