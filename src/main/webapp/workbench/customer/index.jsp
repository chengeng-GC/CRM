<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <%--分页控件--%>
    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
    <script type="text/javascript">

        $(function () {

            //定制字段
            $("#definedColumns > li").click(function (e) {
                //防止下拉菜单消失
                e.stopPropagation();
            });



            //页面加载完毕，展现页面
            pageList(1, 2);

            //为查询按钮添加绑定事件，触发pageList方法
            $("#searchBtn").click(function () {
                //将搜索框汇中的信息保存到隐藏域中，防止其他途径触发pageList方法用未点击查询的搜索框信息查询
                $("#hidden-name").val($.trim($("#search-name").val()));
                $("#hidden-owner").val($.trim($("#search-owner").val()));
                $("#hidden-phone").val($.trim($("#search-phone").val()));
                $("#hidden-website").val($.trim($("#search-website").val()));
                //应该回到第一页，维持每页展现的记录数
                pageList(1, $("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
            })

            //为创建客户按钮绑定事件，展现创建客户模态窗口
            $("#createBtn").click(function () {
                //时间（日历）选择控件
                $(".time").datetimepicker({
                    minView: "month",
                    language:  'zh-CN',
                    format: 'yyyy-mm-dd',
                    autoclose: true,
                    todayBtn: true,
                    pickerPosition: "bottom-left"
                });
                //走后台，取得用户信息列表，为所有者列表添加option
                $.ajax({
                    url : "workbench/customer/getUserList.do",
                    type: "get",
                    dataType:"json",
                    success:function(data){
                        var html="";
                        $.each(data,function (i,n) {
                            html +="<option value='"+n.id+"'>"+n.name+"</option>";
                        })
                        $("#create-owner").html(html);
                        //当前用户作为下拉列表的默认选项
                        //在js中使用el表达式，el表达式一定要套用在字符串中
                        $("#create-owner").val("${user.id}");
                        //所有者下拉框处理完毕后,展现模态窗口
                        $("#createCustomerModal").modal("show");
                    }
                })
            })

            //为保存按钮绑定事件，执行添加操作
            $("#saveBtn").click(function () {
                var name=$.trim($("#create-name").val());
                if (name==null||name=="") {
                    alert("名称不能为空");
                    return ;
                }
                $.ajax({
                    url:"workbench/customer/save.do",
                    data:{
                        "owner":$.trim($("#create-owner").val()),
                        "name":name,
                        "phone":$.trim($("#create-phone").val()),
                        "website":$.trim($("#create-website").val()),
                        "contactSummary":$.trim($("#create-contactSummary").val()),
                        "description":$.trim($("#create-description").val()),
                        "address":$.trim($("#create-address").val()),
                        "nextContactTime":$.trim($("#create-nextContactTime").val())
                    },
                    type: "post",
                    dataType:"json",
                    success:function(data){
                        if (data.success){
                            //添加成功后，刷新市场活动信息列表（局部刷新）
                            //应该回到第一页，维持每页展现的记录数
                            pageList(1,$("#customerPage").bs_pagination('getOption','rowsPerPage'));
                            //清空添加操作的模态窗口
                            $("#customerAddForm")[0].reset();
                            //关闭添加操作的模态窗口
                            $("#createCustomerModal").modal("hide");
                        }
                    }
                })
            })
            //为全选的复选框绑定事件，触发全选操作
            $("#qx").click(function () {
                $("input[name=xz]").prop("checked",this.checked);
            })

            //为动态的选择复选框绑定事件，判断是否全选
            $("#customerBody").on("click",$("input[name=xz]"),function () {
                $("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);
            })



            //为修改按钮绑定事件，打开修改线索模态窗口
            $("#editBtn").click(function () {
                //时间（日历）选择控件
                $(".time").datetimepicker({
                    minView: "month",
                    language:  'zh-CN',
                    format: 'yyyy-mm-dd',
                    autoclose: true,
                    todayBtn: true,
                    pickerPosition: "bottom-left"
                });
                var $xz=$("input[name=xz]:checked");
                if ($xz.length==0){
                    alert("请选择需要修改的记录");
                }else if ($xz.length>1){
                    alert("只能选择一条记录进行修改");
                } else {
                    var id=$xz.val();
                    $.ajax({
                        url:"workbench/customer/getUserListAndCustomer.do",
                        data:{"id":id
                        },
                        type: "get",
                        dataType:"json",
                        success:function(data){
                            //用户列表uList
                            //线索单条 c
                            var html="";
                            $.each(data.uList,function (i,n) {
                                html +="<option value='"+n.id+"'>"+n.name+"</option>";
                            })
                            $("#edit-owner").html(html);


                            //处理单条customer
                            $("#hidden-edit-id").val(data.c.id);
                            $("#edit-name").val(data.c.name);
                            $("#edit-owner").val(data.c.owner);
                            $("#edit-website").val(data.c.website);
                            $("#edit-phone").val(data.c.phone);
                            $("#edit-contactSummary").val(data.c.contactSummary);
                            $("#edit-nextContactTime").val(data.c.nextContactTime);
                            $("#edit-description").val(data.c.description);
                            $("#edit-address").val(data.c.address);

                            //处理完毕后,展现模态窗口
                            $("#editCustomerModal").modal("show");
                        }
                    })
                }
            })

//为更新按钮绑定事件，执行更新操作
            $("#updateBtn").click(function () {
                var name=$.trim($("#edit-name").val());
                if (name==null||name=="") {
                    alert("名称不能为空");
                    return ;
                }
                $.ajax({
                    url:"workbench/customer/update.do",
                    data:{
                        "id":$.trim($("#hidden-edit-id").val()),
                        "owner":$.trim($("#edit-owner").val()),
                        "name":name,
                        "website":$.trim($("#edit-website").val()),
                        "phone":$.trim($("#edit-phone").val()),
                        "contactSummary":$.trim($("#edit-contactSummary").val()),
                        "nextContactTime":$.trim($("#edit-nextContactTime").val()),
                        "description":$.trim($("#edit-description").val()),
                        "address":$.trim($("#edit-address").val())
                    },
                    type: "post",
                    dataType:"json",
                    success:function(data){
                        if (data.success){
                            //更新成功后,局部刷新下页面
                            //当前页数不变，每页的条数不变
                            pageList($("#customerPage").bs_pagination('getOption', 'currentPage'),
                                $("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
                        }else {
                            alert("更新客户失败");
                        }
                        //关闭模态窗口
                        $("#editCustomerModal").modal("hide");
                    }
                })
            })

            //为删除按钮绑定事件,执行线索删除操作
            $("#deleteBtn").click(function () {
                //找到复选框中所有√的jquery对象
                var $xz= $("input[name=xz]:checked");
                if ($xz.length==0){
                    alert("请选择需要删除的记录");
                }else {
                    //给用户一个提示，避免误删
                    if (confirm("确定删除所选中记录吗？")){
                        var param="";
                        //将$xz中的每一个dom对象遍历出来，取其value值，就先当于取得需删除记录的id
                        for (var i=0;i<$xz.length;i++){
                            param += "id="+$($xz[i]).val();
                            //如果不是最后一个元素，需要追加一个&
                            if (i<$xz.length-1){
                                param+="&";
                            }
                        }
                        $.ajax({
                            url:"workbench/customer/delete.do",
                            data:param,
                            type: "post",
                            dataType:"json",
                            success:function(data){
                                if (data.success){
                                    //删除成功后,局部刷新下页面
                                    //回到第一页，每页条数不变
                                    pageList(1,$("#customerPage").bs_pagination('getOption','rowsPerPage'));
                                }else {
                                    alert("删除客户失败");
                                }
                            }
                        })
                    }
                }
            })


        });


        function pageList(pageNo, pageSize) {
            //消除复选框的√
            $("#qx").prop("checked",false);

            //查询前，将隐藏域中保存的信息取出，重新赋予到搜索框中
            $("#search-name").val($.trim($("#hidden-name").val()));
            $("#search-owner").val($.trim($("#hidden-owner").val()));
            $("#search-phone").val($.trim($("#hidden-phone").val()));
            $("#search-website").val($.trim($("#hidden-website").val()));

            $.ajax({
                url: "workbench/customer/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "name": $.trim($("#search-name").val()),
                    "owner": $.trim($("#search-owner").val()),
                    "phone": $.trim($("#search-phone").val()),
                    "website": $.trim($("#search-website").val())
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    //客户列表 dataList
                    //分页插件所需total
                    var html = "";
                    $.each(data.dataList, function (i, n) {
                        html += '<tr>';
                        html += '	<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
                        html += '			<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/customer/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';
                        html += '	<td>'+n.owner+'</td>';
                        html += '	<td>'+n.phone+'</td>';
                        html += '	<td>'+n.website+'</td>';
                        html += '</tr>';
                    })
                    $("#customerBody").html(html);
                    //计算总页数
                    var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

                    //使用分页插件
                    $("#customerPage").bs_pagination({
                        currentPage: pageNo, // 页码
                        rowsPerPage: pageSize, // 每页显示的记录条数
                        maxRowsPerPage: 20, // 每页最多显示的记录条数
                        totalPages: totalPages, // 总页数
                        totalRows: data.total, // 总记录条数

                        visiblePageLinks: 3, // 显示几个卡片

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        showRowsDefaultInfo: true,

                        onChangePage : function(event, data){
                            pageList(data.currentPage , data.rowsPerPage);
                        }
                    });


                }
            })
        }


    </script>
</head>
<body>
<input type="hidden" id="hidden-name">
<input type="hidden" id="hidden-owner">
<input type="hidden" id="hidden-phone">
<input type="hidden" id="hidden-website">
<!-- 创建客户的模态窗口 -->
<div class="modal fade" id="createCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" id="customerAddForm" role="form">

                    <div class="form-group">
                        <label for="create-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-owner">

                            </select>
                        </div>
                        <label for="create-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-name">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-description"></textarea>
                        </div>
                    </div>
                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="create-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address1" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改客户的模态窗口 -->
<div class="modal fade" id="editCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <input type="hidden" id="hidden-edit-id">
                    <div class="form-group">
                        <label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-owner">

                            </select>
                        </div>
                        <label for="edit-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-name" >
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone" >
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-description"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime2" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>客户列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="search-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="search-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" type="text" id="search-phone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司网站</div>
                        <input class="form-control" type="text" id="search-website">
                    </div>
                </div>

                <button type="button" id="searchBtn" class="btn btn-default">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createBtn" ><span
                        class="glyphicon glyphicon-plus" ></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>

        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>公司座机</td>
                    <td>公司网站</td>
                </tr>
                </thead>
                <tbody id="customerBody">
                <%--						<tr>--%>
                <%--							<td><input type="checkbox" /></td>--%>
                <%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/customer/detail.jsp';">动力节点</a></td>--%>
                <%--							<td>zhangsan</td>--%>
                <%--							<td>010-84846003</td>--%>
                <%--							<td>http://www.bjpowernode.com</td>--%>
                <%--						</tr>--%>
                <%--                        <tr class="active">--%>
                <%--                            <td><input type="checkbox" /></td>--%>
                <%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/customer/detail.jsp';">动力节点</a></td>--%>
                <%--                            <td>zhangsan</td>--%>
                <%--                            <td>010-84846003</td>--%>
                <%--                            <td>http://www.bjpowernode.com</td>--%>
                <%--                        </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 30px;">
            <div id="customerPage">
            </div>
        </div>

    </div>

</div>
</body>
</html>