#### 相关的依赖

```xml
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.13.3</version>
</dependency>
```



#### [spring boot rest api，控制返回json数据，过滤部分字段](https://blog.csdn.net/qq_32352777/article/details/123688149)

#### 使用 Jackson 的 @JsonView 指定返回json的某些字段

1. 首先需要定义两个试图，用来标识哪个接口返回哪些字段

我这里定义了两个：

```java
// 指定的api接口
public interface JsonApiViewProfile {
}
// 另外的一个接口，和上面接口返回的json字段有几个差别
public interface JsonStockViewProfile {
}
```

2. 在调用的controller中指定

```java
@RequestMapping(value = "/getSingleStockList", method = RequestMethod.POST)
@JsonView({JsonStockViewProfile.class})
public StockResponse getSingleStockList(@RequestBody StockForm stockForm) {
    StockResponse response = new StockResponse();
    if (stockForm.isAnnualReport()) {
        Page<ReportArRec> page = arService.pageQuery(stockForm);
        StockResponse.buildRes(page, response);
    } else if (stockForm.isCornerStoneInvestor()) {
        Page<ReportCornerstoneRec> page = cornerstoneService.pageQuery(stockForm);
        StockResponse.buildRes(page, response);
    } else if (stockForm.isSdiDatabase()) {
        Page<ReportSdiRec> page = sdiService.pageQuery(stockForm);
        StockResponse.buildRes(page, response);
    } else if (stockForm.isIpoAllocations()) {
        Page<ReportIpoRec> page = ipoService.pageQuery(stockForm);
        StockResponse.buildRes(page, response);
    } else {
        response.setReturnCode(ErrorCode.Failed);
    }
    return response;
}
```

指定的api接口

```java
@RequestMapping(value = "/shareholders", method = RequestMethod.GET)
@JsonView({JsonApiViewProfile.class})
public ApiStockResponse getShareholders(@RequestParam(name = "quarter", required = false, defaultValue = "") String quarter,
                                        @RequestParam(name = "stockCode", required = false, defaultValue = "") String[] stockCode,
                                        @RequestParam(name = "year", required = false, defaultValue = "") String year) {
    boolean b = ApiParamCheckUtil.checkParamEligible(quarter, year);
    if (!b) {
        return ApiStockResponse.buildRes(ErrorCode.InvalidRequestFormat,
                null, null);
    }
    int searchYear = Integer.parseInt(year);
    StockForm form = StockForm.builder().stockIds(List.of(stockCode)).quarter(quarter).year(searchYear).build();
    List<StockVo> allStockList = stockService.getAllStockList(form);
    if (allStockList.size() > ApiStockResponse.MAX_RESULT) {
        return ApiStockResponse.buildRes(ErrorCode.DataVolumeExceeded,
                null, null);
    }
    List<ReportControlTableRec> allStockStatus = reportControlTableService.getAllStockStatus(form);
    return ApiStockResponse.buildRes(ErrorCode.Success, allStockList, allStockStatus);
}
```

这两个接口需要返回的json字段不一样

3. 定义返回的json

```java
public class IpoVo extends StockVo {
    @JsonView({JsonStockViewProfile.class, JsonApiViewProfile.class})
    private String src;

    @JsonView({JsonStockViewProfile.class, JsonApiViewProfile.class})
    private String ric;

    @JsonView({JsonStockViewProfile.class, JsonApiViewProfile.class})
    private String hldr;

    @JsonView({JsonStockViewProfile.class, JsonApiViewProfile.class})
    private String updateDate;

    @JsonView({JsonStockViewProfile.class, JsonApiViewProfile.class})
    private Integer seq;

    // 这个只在 stock 的接口返回，上面的则两个接口都需要返回
    @JsonView({JsonStockViewProfile.class})
    private String stkCd;

    @JsonView({JsonStockViewProfile.class})
    private String rptYr;

    @JsonView({JsonStockViewProfile.class})
    private String qtr;
}
```

具体的response里面也需要加上 @JsonView 注解。

```java
public class StockResponse extends BaseHsicmsResp<NullOutput> {
    @JsonView({JsonStockViewProfile.class})
    private StockVo stockVo;

    @JsonView({JsonStockViewProfile.class})
    private List<StockVo> list = new ArrayList<>();

    @JsonView({JsonStockViewProfile.class})
    private Map<String, List<StockVo>> groupByStockCodeList = new HashMap<>();

    @JsonView({JsonStockViewProfile.class})
    private long totalPage;

    @JsonView({JsonStockViewProfile.class})
    private long totalCount;
}
```

另一个response

```java
public class ApiStockResponse extends BaseHsicmsResp<NullOutput> {
    @JsonView({JsonApiViewProfile.class})
    private int numStkRtd;

    @JsonView({JsonApiViewProfile.class})
    private List<StockVo> stockDetail = new ArrayList<>();
}
```

这样返回的json会相差上面的三个字段。

```java
// 这个只在 stock 的接口返回，上面的则两个接口都需要返回
@JsonView({JsonStockViewProfile.class})
private String stkCd;

@JsonView({JsonStockViewProfile.class})
private String rptYr;

@JsonView({JsonStockViewProfile.class})
private String qtr;
```

但是这个有个问题就是，父类中的字段需要返回也需要加上这个注解，对于其他的接口请求不是很好。此时我们可以使用另一种方法，就是接口直接返回json字符串，手动指定哪些字段需要序列化。

#### 使用@JsonFilter手动指定序列化字段

[Jackson ObjectMapper的权威指南--序列化和反序列化Java对象](https://juejin.cn/post/7114895114559815717)

1. 首先我们需要先指定一个 jsonfilter 的名称

```java
@Data
@JsonFilter("apiStockFilter")
public class CornerStoneVo extends StockVo {
    private String src;

    private String ric;

    private String hldr;

    private String nmOfCsiEng;

    private String nmOfCsiChi;

    private String shType;

    private String shCls;

    private Long noOfShsInt;

    private Long dupSh;

    private String dupW;

    private String lockDate;

    private BigDecimal pctIssVotShs;

    private String relGrp;

    private String lastNoteDate;

    private String recDate;

    private String updateDate;

    private Integer seq;

    // These attributes do not require
//    @JsonIgnore
    private String stkCd;

//    @JsonIgnore
    private String rptYr;

//    @JsonIgnore
    private String qtr;
}
```

@JsonFilter("apiStockFilter") 可以和 @JsonIgnore、@JsonIgnoreProperties 一起使用

```java
@Data
@JsonFilter("apiStockFilter")
@JsonIgnoreProperties({"stkCd", "rptYr", "qtr", "uploadDate"})
public class LockupUrlVo extends StockVo {
    private String source;

    // ric -> arvo.ric
    private String ric;

    private List<String> url;

    // These attributes do not require
    private String stkCd;

    private String rptYr;

    private String qtr;

    private String uploadDate;
}
```

StockVo 是一个父类，返回的字段在它的子类中，返回的json字段会少上面三个字段。

```java
@Getter
@Setter
@NoArgsConstructor
@Log4j2
public class ApiStockResponse extends BaseHsicmsResp<NullOutput> {
    private int numStkRtd;
    private List<StockVo> stockDetail = new ArrayList<>();
    public static final Integer MAX_RESULT = 10000;

    public static String buildRes(ErrorCode errorCode, List<StockVo> stockVoList,
                                            List<ReportControlTableRec> controlTableRecList) {
        ApiStockResponse res = new ApiStockResponse();
		// 省略一些逻辑
        SimpleFilterProvider filterProvider = new SimpleFilterProvider();
        SimpleBeanPropertyFilter beanPropertyFilter = SimpleBeanPropertyFilter.serializeAllExcept("stkCd", "rptYr", "qtr");
        filterProvider.addFilter("apiStockFilter", beanPropertyFilter);
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.setFilterProvider(filterProvider);
        String json;
        try {
            json = objectMapper.writeValueAsString(res);
            // 返回的 bigdecimal 科学计数法问题
            objectMapper.enable(DeserializationFeature.USE_BIG_DECIMAL_FOR_FLOATS);
          objectMapper.configure(DeserializationFeature.USE_BIG_DECIMAL_FOR_FLOATS,true);
        } catch (JsonProcessingException e) {
            log.error("json serialize fail: {}", e.getMessage());
            json = "{" +
                    "  \"returnCode\": \"00000001\"," +
                    "  \"respMsg\": \"Fail\"," +
                    "  \"numStkRtd\": 0," +
                    "  \"stockDetail\": []," +
                    "  \"output\": \"null\"" +
                    "}";
        }
        return json;
    }
}
```

返回结果：

```json
{
    "returnCode": "00000000",
    "respMsg": null,
    "numStkRtd": 1,
    "stockDetail": [
		{
            "src": "corner",
            "ric": "1358.HK",
            "hldr": "",
            "nmOfCsiEng": "Investment Company 178",
            "nmOfCsiChi": "投資公司 178",
            "shType": "Type",
            "shCls": "Class",
            "noOfShsInt": 166081,
            "dupSh": 123,
            "dupW": "",
            "lockDate": "2023-08-26",
            "pctIssVotShs": 11.6723447215,
            "relGrp": "Group",
            "lastNoteDate": "2023-05-05",
            "recDate": "2023-08-26",
            "updateDate": "2023-06-14",
            "seq": 178
        }
   ]
}
```

还可以指定其他的一些属性：

```java
@JsonFilter("userFilter")  //在这里加注解并且指定过滤器的名称
public class User {

  private String username;
  private String password;
  private Integer age;
}

public static void main(String[] args) throws IOException {
    SimpleFilterProvider filterProvider = new SimpleFilterProvider();
    filterProvider.addFilter("userFilter",   //添加过滤器名称
                             SimpleBeanPropertyFilter.serializeAllExcept("username", "password")); //这里指定不序列化的属性
    /*        Set exclude = new HashSet();
        exclude.add("username");
        exclude.add("password");
        filterProvider.addFilter("userFilter",
                SimpleBeanPropertyFilter.serializeAllExcept(exclude)); //这里指定不序列化的属性也可以放到Set集合里面
        filterProvider.addFilter("userFilter",
                SimpleBeanPropertyFilter.serializeAll());  // serializeAll()序列化所有属性，
        filterProvider.addFilter("userFilter",
                SimpleBeanPropertyFilter.filterOutAllExcept("age")); //只序列化这里包含的属性*/
    ObjectMapper mapper = new ObjectMapper();
    mapper.setFilterProvider(filterProvider);
    User user = new User();
    user.setUsername("小明");
    user.setPassword("123");
    user.setAge(18);
    String s = mapper.writer().withDefaultPrettyPrinter().writeValueAsString(user);
    System.out.println("我是序列化" + s);
    User user1 = mapper.readValue("{\"username\":\"小明\",\"password\":\"123\",\"age\":18}", User.class);
    System.out.println("我是反序列化" + user1);  //这里注意只是在序列化的时候过滤字段，在反序列化的时候是不过滤的
}
```

输出：

```tex
我是序列化{
  "age" : 18
}
我是反序列化User{username='小明', password='123', age=18}
```

#### 使用 Jackson @JsonFormat 注解后端接收前端传递的参数，有时间字段

https://www.baeldung.com/jackson-jsonformat

源码翻译出来的注释

用于配置如何序列化属性值的详细信息的通用注释。与大多数其他Jackson注释不同，注释没有特定的通用解释:相反，效果取决于被注释的属性的数据类型(或者更具体地说，**取决于所使用的反序列化器和序列化器**)。

项目中使用的是这样的反序列化方式。ObjectMapper

```java
public static ObjectMapper newDefaultMapper() {
  ObjectMapper mapper = new ObjectMapper();
  mapper.registerModule(new Jdk8Module());
  mapper.registerModule(new JavaTimeModule());
  mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
  return mapper;
}
```

最终是走的这个方法进行序列化的

`com.fasterxml.jackson.databind.ObjectMapper#treeToValue`

所以会识别到加的注解。

实体类：

```java
public class User {
    private String firstName;
    private String lastName;
    private Date createdDate = new Date();

    // standard constructor, setters and getters
}
```

使用 *@JsonFormat* to specify the format to serialize the *createdDate* field。The data format used for the *pattern* argument is specified by *[SimpleDateFormat](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/text/SimpleDateFormat.html)*:

```java
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd@HH:mm:ss.SSSZ")
private Date createdDate;
```

使用之后

```json
{"firstName":"John","lastName":"Smith","createdDate":"2016-12-18@07:53:34.740+0000"}
```

也可以用在getter上

```java
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
public Date getCurrentDate() {
    return new Date();
}
// 输出: { ... , "currentDate":"2016-12-18", ...}
```

指定 Locale

```java
@JsonFormat(
  shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd@HH:mm:ss.SSSZ", locale = "en_GB")
public Date getCurrentDate() {
    return new Date();
}
```

指定shape

```java
@JsonFormat(shape = JsonFormat.Shape.NUMBER)
public Date getDateNum() {
    return new Date();
}
// { ..., "dateNum":1482054723876 }
```

项目中使用

```java
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyyMMddHHmmss", timezone = "GMT+8")
private Date dateFrom;
```

获取默认时区

```java
public static void main(String[] args) throws IOException {
    TimeZone aDefault = TimeZone.getDefault();
    System.out.println(aDefault.getID());
    //输出结果    Asia/Shanghai
}
```



#### 使用 注解@DateTimeFormat 转化前端时间到后端

首先需要引入是spring还有jodatime

```xml
<dependency>
    <groupId>joda-time</groupId>
    <artifactId>joda-time</artifactId>
    <version>2.3</version>
</dependency>
```

前端接收实体类，可以同时使用这两个注解。

```java
@DateTimeFormat(pattern = "yyyy-MM-dd")
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss",timezone="GMT+8")
private Date symstarttime;

@DateTimeFormat(pattern = "yyyy-MM-dd")
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss",timezone="GMT+8")
private Date symendtime;
```