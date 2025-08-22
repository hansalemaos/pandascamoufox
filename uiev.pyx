from camoufox.sync_api import Camoufox
from pandas import DataFrame as pd_DataFrame
cimport cython
import cython
cimport numpy as np
import numpy as np
from pandas.core.base import PandasObject
from pandas.core.frame import DataFrame, Series, Index
import pandas as pd

cdef:
    str ResetAll = "\033[0m"
    str LightRed = "\033[91m"
    str LightGreen = "\033[92m"
    str LightYellow = "\033[93m"
    str LightBlue = "\033[94m"
    str LightMagenta = "\033[95m"
    str LightCyan = "\033[96m"
    str White = "\033[97m"
    list[str] colors2rotate=[
        LightRed,
        LightGreen,
        LightYellow,
        LightBlue,
        LightMagenta,
        LightCyan,
        White,
    ]

@cython.nonecheck(True)
def pdp(
    object df,
    Py_ssize_t column_rep=70,
    Py_ssize_t max_lines=0,
    Py_ssize_t max_colwidth=300,
    Py_ssize_t ljust_space=2,
    str sep=" | ",
    bint vtm_escape=True,
):
    cdef:
        dict[Py_ssize_t, np.ndarray] stringdict= {}
        dict[Py_ssize_t, Py_ssize_t] stringlendict= {}
        list[str] df_columns, allcolumns_as_string
        Py_ssize_t i, len_a, len_df_columns, lenstr, counter, j, len_stringdict0, k, len_stringdict
        str stringtoprint, dashes, dashesrep
        np.ndarray a
        str tmpstring=""
        list[str] tmplist=[]
        str tmp_newline="\n"
        str tmp_rnewline="\r"
        str tmp_newline2="\\n"
        str tmp_rnewline2="\\r"
    if vtm_escape:
        print('\033[12:2p')
    if len(df) > max_lines and max_lines > 0:
        a = df.iloc[:max_lines].reset_index(drop=False).T.__array__()
    else:
        a = df.iloc[:len(df)].reset_index(drop=False).T.__array__()
    try:
        df_columns = ["iloc"] + [str(x) for x in df.columns]
    except Exception:
        try:
            df_columns = ["iloc",str(df.name)]
        except Exception:
            df_columns = ["iloc",str(0)]
    len_a=len(a)
    for i in range(len_a):
        try:
            stringdict[i] = np.array([repr(qx)[:max_colwidth] for qx in a[i]])
        except Exception:
            stringdict[i] = np.array([ascii(qx)[:max_colwidth] for qx in a[i]])
        stringlendict[i] = (stringdict[i].dtype.itemsize // 4) + ljust_space
    for i in range(len_a):
        lenstr = len(df_columns[i])
        if lenstr > stringlendict[i]:
            stringlendict[i] = lenstr + ljust_space
        if max_colwidth > 0:
            if stringlendict[i] > max_colwidth:
                stringlendict[i] = max_colwidth

    allcolumns_as_string = []
    len_df_columns=len(df_columns)
    for i in range(len_df_columns):
        stringtoprint = str(df_columns[i])[: stringlendict[i]].ljust(stringlendict[i])
        allcolumns_as_string.append(stringtoprint)
    allcolumns_as_string_str = sep.join(allcolumns_as_string) + sep
    dashes = "-" * (len(allcolumns_as_string_str) + 2)
    dashesrep = dashes + "\n" + allcolumns_as_string_str + "\n" + dashes
    counter = 0
    len_stringdict0 = len(stringdict[0])
    len_stringdict=len(stringdict)
    for j in range(len_stringdict0):
        if column_rep > 0:
            if counter % column_rep == 0:
                tmplist.append(dashesrep)
        counter += 1
        tmpstring=""
        for k in range(len_stringdict):
            tmpstring+=((
                f"{colors2rotate[k % len(colors2rotate)] + stringdict[k][j][: stringlendict[k]].replace(tmp_newline,tmp_newline2).replace(tmp_rnewline, tmp_rnewline2).ljust(stringlendict[k])}{ResetAll}{sep}"
            ))
        tmplist.append(tmpstring)
    print("\n".join(tmplist))
    return ""

cpdef print_col_width_len(object df):
    try:
        pdp(
            pd_DataFrame(
                [df.shape[0], df.shape[1]], index=["rows", "columns"]
            ).T.rename(
                {0: "DataFrame"},
            ),
        )
    except Exception:
        pdp(
            pd_DataFrame([df.shape[0]], index=["rows"]).T.rename({0: "Series"}),
        )


cpdef pandasprintcolor(self):
    pdp(pd_DataFrame(self.reset_index().__array__(), columns=['index']+[str(x) for x in self.columns],copy=False))
    print_col_width_len(self.__array__())

    return ""

def copy_func(f):
    cdef:
        object g
        list t
        Py_ssize_t i
    g = lambda *args: f(*args)
    t = list(filter(lambda prop: not ("__" in prop), dir(f)))
    i = 0
    while i < len(t):
        setattr(g, t[i], getattr(f, t[i]))
        i += 1
    return g


cpdef pandasprintcolor_s(self):
    return pandasprintcolor(self.to_frame())

cpdef pandasindexcolor(self):
    pdp(pd_DataFrame(self.__array__()[: self.print_stop].reshape((-1, 1))))
    return ""


cpdef reset_print_options():
    PandasObject.__str__ = copy_func(PandasObject.old__str__)
    PandasObject.__repr__ = copy_func(PandasObject.old__repr__)
    DataFrame.__repr__ = copy_func(DataFrame.old__repr__)
    DataFrame.__str__ = copy_func(DataFrame.old__str__)
    Series.__repr__ = copy_func(Series.old__repr__)
    Series.__str__ = copy_func(Series.old__str__)
    Index.__repr__ = copy_func(Index.old__repr__)
    Index.__str__ = copy_func(Index.old__str__)


def substitute_print_with_color_print(
    print_stop: int = 69, max_colwidth: int = 300, repeat_cols: int = 70
):
    if not hasattr(pd, "color_printer_active"):
        PandasObject.old__str__ = copy_func(PandasObject.__str__)
        PandasObject.old__repr__ = copy_func(PandasObject.__repr__)
        DataFrame.old__repr__ = copy_func(DataFrame.__repr__)
        DataFrame.old__str__ = copy_func(DataFrame.__str__)
        Series.old__repr__ = copy_func(Series.__repr__)
        Series.old__str__ = copy_func(Series.__str__)
        Index.old__repr__ = copy_func(Index.__repr__)
        Index.old__str__ = copy_func(Index.__str__)

    PandasObject.__str__ = lambda x: pandasprintcolor(x)
    PandasObject.__repr__ = lambda x: pandasprintcolor(x)
    PandasObject.print_stop = print_stop
    PandasObject.max_colwidth = max_colwidth
    PandasObject.repeat_cols = repeat_cols
    DataFrame.__repr__ = lambda x: pandasprintcolor(x)
    DataFrame.__str__ = lambda x: pandasprintcolor(x)
    DataFrame.print_stop = print_stop
    DataFrame.max_colwidth = max_colwidth
    DataFrame.repeat_cols = repeat_cols
    Series.__repr__ = lambda x: pandasprintcolor_s(x)
    Series.__str__ = lambda x: pandasprintcolor_s(x)
    Series.print_stop = print_stop
    Series.max_colwidth = max_colwidth
    Series.repeat_cols = repeat_cols
    Index.__repr__ = lambda x: pandasindexcolor(x)
    Index.__str__ = lambda x: pandasindexcolor(x)
    Index.print_stop = print_stop
    Index.max_colwidth = max_colwidth
    Index.repeat_cols = 10000000
    pd.color_printer_activate = substitute_print_with_color_print
    pd.color_printer_reset = reset_print_options
    pd.color_printer_active = True

def qq_ds_print_nolimit(self, **kwargs):
    try:
        pdp(
            pd_DataFrame(self.reset_index().__array__(), columns=['index']+[str(x) for x in self.columns],copy=False),
            max_lines=0,
            **kwargs,
        )
        print_col_width_len(self.__array__())
    except Exception:
        try:
            pdp(
                pd_DataFrame(self.reset_index().__array__(), columns=['index',self.name],copy=False),
                max_lines=0,
            )
        except Exception:
            pdp(
                pd_DataFrame(self.__array__(),copy=False),
                max_lines=0,
            )
        print_col_width_len(self.__array__())
    return ""


def qq_d_print_columns(self, **kwargs):
    pdp(
        pd_DataFrame(self.columns.__array__().reshape((-1, 1))),
        max_colwidth=0,
        max_lines=0,
        **kwargs,
    )
    return ""


def qq_ds_print_index(self, **kwargs):
    pdp(pd_DataFrame(self.index.__array__().reshape((-1, 1))),    max_lines=0, max_colwidth=0, **kwargs)
    return ""


cpdef add_printer(overwrite_pandas_printer=False):

    PandasObject.ds_color_print_all = qq_ds_print_nolimit
    DataFrame.d_color_print_columns = qq_d_print_columns
    DataFrame.d_color_print_index = qq_ds_print_index
    if overwrite_pandas_printer:
        substitute_print_with_color_print()


@cython.final
cdef class ExecuteMethod:
    """
    A lightweight callable wrapper that binds an element with one of its methods.

    This class allows deferred method calls on an object (typically a DOM element
    when working with Playwright). If the method exists on the bound element,
    calling the instance will invoke that method with the provided arguments.

    Attributes
    ----------
    element : object
        The object on which the method should be executed.
    method : object
        The name of the method to call on the element.

    Methods
    -------
    __call__(*a, **k)
        Invokes the specified method on the bound element with the provided arguments.
        Returns None if the element does not have the method.
    __repr__()
        Returns a simplified string representation of the callable interface.
    __str__()
        Returns a string representing the callable signature.
    """
    cdef:
        object element
        object method
    def __init__(self, element, method):
        self.element = element
        self.method = method

    def __call__(self, *a, **k):
        return (
            getattr(self.element, self.method)(*a, **k)
            if hasattr(self.element, self.method)
            else None
        )

    def __repr__(self):
        return f"(*a, **k)"

    def __str__(self):
        return f"(*a, **k)"


class CamoufoxDf:
    """
    A convenience wrapper around Camoufox that extracts DOM elements into a Pandas DataFrame.

    This class launches a Camoufox browser, opens a page, and provides a method
    to collect detailed attributes, styles, and available actions of DOM elements
    into a structured `pandas.DataFrame`. Each row in the DataFrame corresponds
    to one DOM element, with columns containing both properties and bound
    interaction methods (click, hover, type, etc.).

    Attributes
    ----------
    browser : Camoufox
        The underlying Camoufox browser instance.
    page : CamoufoxPage
        The active page created within the browser.

    Methods
    -------
    close()
        Closes the browser and cleans up resources.
    get_df(query_selector="*")
        Queries DOM elements matching the given CSS selector and returns
        a DataFrame containing their attributes and executable methods.
    """
    def __init__(self, *args, **kwargs):
        """
        Initialize a CamoufoxDf instance and launch a Camoufox browser session.

        This constructor creates a new `Camoufox` browser context using the
        provided arguments, automatically enters the context, and opens a new
        browser page for DOM inspection and interaction.

        Parameters
        ----------
        *args : tuple
            Positional arguments forwarded directly to the `Camoufox` constructor.
        **kwargs : dict
            Keyword arguments forwarded directly to the `Camoufox` constructor.

        Attributes
        ----------
        browser : Camoufox
            The active Camoufox browser context entered via `__enter__`.
        page : CamoufoxPage
            A new page object created from the browser, used to query and interact with DOM elements.
        """
        self.browser = Camoufox(*args, **kwargs).__enter__()
        self.page = self.browser.new_page()

    def close(self):
        """
        Close the Camoufox browser session.

        This method explicitly calls the browser's `__exit__` method,
        releasing all resources associated with the browser context.
        After calling this, the instance should no longer be used
        to interact with the page or DOM elements.
        """
        self.browser.__exit__(None,None,None)

    def get_df(self, str query_selector="*"):
        """
        Query DOM elements and return their attributes and actions as a DataFrame.

        This method selects all elements on the current page that match the given
        CSS selector and constructs a `pandas.DataFrame` where each row corresponds
        to one element. The DataFrame includes both static attributes (tag name,
        id, text, styles, geometry, etc.) and callable methods that allow direct
        interaction with the elements (e.g., click, hover, type).

        Parameters
        ----------
        query_selector : str, optional
            A CSS selector string used to filter DOM elements.
            Defaults to "*" (all elements).

        Returns
        -------
        pandas.DataFrame
            A DataFrame where each row represents a DOM element with its
            attributes and executable bound methods.
        """
        return pd_DataFrame(
            [
                {
                    "aa_element": el,
                    **el.evaluate("""
        el => {
            // alle Attribute sammeln
            const aaattributes = {};
            for (const attr of el.attributes) {
                aaattributes[attr.name] = attr.value;
            }
            const recti = el.getBoundingClientRect();
            return {
                aa_tag: el.tagName,
                aa_id: el.id || null,
                aa_classes: Array.from(el.classList),
                aa_text: el.innerText,
                aa_html: el.outerHTML,
                aa_value: ('value' in el) ? el.value : null,
                aa_title: el.title || null,
                aa_dataset: el.dataset,
                aa_x:recti.x,
                aa_y:recti.y,
                aa_width:recti.width,
                aa_height:recti.height,
                aa_top:recti.top,
                aa_right:recti.right,
                aa_bottom:recti.bottom,
                aa_left:recti.left,
                aa_offsetTop: el.offsetTop,
                aa_offsetLeft: el.offsetLeft,
                aa_offsetWidth: el.offsetWidth,
                aa_offsetHeight: el.offsetHeight,
                aa_display: window.getComputedStyle(el).display,
                aa_visibility: window.getComputedStyle(el).visibility,
                aa_opacity: window.getComputedStyle(el).opacity,
                aa_color: window.getComputedStyle(el).color,
                aa_background: window.getComputedStyle(el).backgroundColor,
                aa_parentTag: el.parentElement ? el.parentElement.tagName : null,
                aa_childrenCount: el.children.length,
                aa_siblingBefore: el.previousElementSibling ? el.previousElementSibling.tagName : null,
                aa_siblingAfter: el.nextElementSibling ? el.nextElementSibling.tagName : null,
                aa_attributes: aaattributes
            };
        }
        """),
                    "bb_dispatch_event": ExecuteMethod(el, "dispatch_event"),
                    "bb_scroll_into_view_if_needed": ExecuteMethod(
                        el, "scroll_into_view_if_needed"
                    ),
                    "bb_hover": ExecuteMethod(el, "hover"),
                    "bb_click": ExecuteMethod(el, "click"),
                    "bb_dblclick": ExecuteMethod(el, "dblclick"),
                    "bb_select_option": ExecuteMethod(el, "select_option"),
                    "bb_tap": ExecuteMethod(el, "tap"),
                    "bb_fill": ExecuteMethod(el, "fill"),
                    "bb_select_text": ExecuteMethod(el, "select_text"),
                    "bb_input_value": ExecuteMethod(el, "input_value"),
                    "bb_set_input_files": ExecuteMethod(el, "set_input_files"),
                    "bb_focus": ExecuteMethod(el, "focus"),
                    "bb_type": ExecuteMethod(el, "type"),
                    "bb_press": ExecuteMethod(el, "press"),
                    "bb_set_checked": ExecuteMethod(el, "set_checked"),
                    "bb_check": ExecuteMethod(el, "check"),
                    "bb_uncheck": ExecuteMethod(el, "uncheck"),
                    "bb_screenshot": ExecuteMethod(el, "screenshot"),
                    "bb_query_selector": ExecuteMethod(el, "query_selector"),
                    "bb_query_selector_all": ExecuteMethod(el, "query_selector_all"),
                    "bb_eval_on_selector": ExecuteMethod(el, "eval_on_selector"),
                    "bb_eval_on_selector_all": ExecuteMethod(
                        el, "eval_on_selector_all"
                    ),
                    "bb_wait_for_element_state": ExecuteMethod(
                        el, "wait_for_element_state"
                    ),
                    "bb_wait_for_selector": ExecuteMethod(el, "wait_for_selector"),
                    "bb_evaluate": ExecuteMethod(el, "evaluate"),
                    "bb_evaluate_handle": ExecuteMethod(el, "evaluate_handle"),
                    "bb_dispose": ExecuteMethod(el, "dispose"),
                    "bb_on": ExecuteMethod(el, "on"),
                    "bb_once": ExecuteMethod(el, "once"),
                    "bb_remove_listener": ExecuteMethod(el, "remove_listener"),
                }
                for el in self.page.query_selector_all(query_selector)
            ],
            dtype="object",
        )

add_printer(True)
