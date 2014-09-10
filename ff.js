function getPageCountList (current_page, page_count) {
    var list = []; 
    if (page_count <= __LIST_MAX__) {
        for (var index = 0 ; index < page_count; index ++) {
            list[index] = index;
        }
    } else {
        var start = current_page - Math.ceil(__LIST_MAX__ / 2); 
        start = start < 0 ? 0:start;
        start = start + __LIST_MAX__ >= page_count ? page_count - __LIST_MAX__: start;
        for (var index = 0 ; index < __LIST_MAX__; index ++) {
            list[index] = start + index;
        }
    }   
    return list;
}
