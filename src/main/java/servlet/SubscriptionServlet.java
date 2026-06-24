package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class SubscriptionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        if ("cancel".equals(action)) {
            db.cancelSubscription(Integer.parseInt(req.getParameter("id")));
            resp.sendRedirect("SubscriptionServlet?action=list");
        } else if ("txn".equals(action)) {
            // 【高阶技术5】事务演示：退订+新建
            int oldSubId = Integer.parseInt(req.getParameter("oldSubId"));
            int custId = Integer.parseInt(req.getParameter("customerId"));
            int newsId = Integer.parseInt(req.getParameter("newspaperId"));
            int qty = Integer.parseInt(req.getParameter("quantity"));
            String date = req.getParameter("startDate");
            String result = db.unsubscribeAndResubscribe(oldSubId, custId, newsId, qty, date);
            req.getSession().setAttribute("txnResult", result);
            resp.sendRedirect("SubscriptionServlet?action=list");
        } else {
            req.getSession().setAttribute("subscriptions", db.listSubscriptions());
            req.getSession().setAttribute("customers", db.listCustomers());
            req.getSession().setAttribute("newspapers", db.listNewspapers());
            resp.sendRedirect("subscription.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        DB db = new DB();
        int custId = Integer.parseInt(req.getParameter("customerId"));
        int newsId = Integer.parseInt(req.getParameter("newspaperId"));
        int qty = Integer.parseInt(req.getParameter("quantity"));
        String date = req.getParameter("startDate");
        boolean ok = db.addSubscription(custId, newsId, qty, date);
        resp.getWriter().println(ok ? "<script>alert('订阅成功');location.href='SubscriptionServlet?action=list';</script>"
                                    : "<script>alert('订阅失败');history.back();</script>");
    }
}
