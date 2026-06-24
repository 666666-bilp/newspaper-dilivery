package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.Customer;
import java.io.IOException;

public class CustomerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            boolean ok = db.deleteCustomer(id);
            resp.sendRedirect("CustomerServlet?action=list");
        } else if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            Customer c = db.getCustomer(id);
            req.setAttribute("customer", c);
            req.setAttribute("communities", db.listCommunities());
            req.getRequestDispatcher("customer.jsp?mode=edit").forward(req, resp);
        } else {
            req.getSession().setAttribute("customers", db.listCustomers());
            req.getSession().setAttribute("communities", db.listCommunities());
            resp.sendRedirect("customer.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();
        Customer c = new Customer();
        c.setName(req.getParameter("name"));
        c.setPhone(req.getParameter("phone"));
        c.setAddress(req.getParameter("address"));
        c.setCommunityId(Integer.parseInt(req.getParameter("communityId")));
        boolean ok;
        if ("update".equals(action)) {
            c.setId(Integer.parseInt(req.getParameter("id")));
            ok = db.updateCustomer(c);
        } else {
            ok = db.addCustomer(c);
        }
        resp.getWriter().println(ok ? "<script>alert('操作成功');location.href='CustomerServlet?action=list';</script>"
                                    : "<script>alert('操作失败');history.back();</script>");
    }
}
