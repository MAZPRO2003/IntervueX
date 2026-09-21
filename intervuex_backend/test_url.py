import asyncio
import httpx

async def test():
    url = "https://www.naukri.com/job-listings-opportunities-with-hcltech-java-developer-fresher-hcltech-chennai-0-to-0-years-070926033769?utmcampaign=androidjd&utmsource=share&src=sharedjd"
    
    # Try direct
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    }
    
    async with httpx.AsyncClient() as client:
        res1 = await client.get(url, headers=headers)
        print("Direct:", res1.status_code)
        
        # Try Jina
        res2 = await client.get(f"https://r.jina.ai/{url}")
        print("Jina:", res2.status_code)
        print(res2.text[:500])
        
if __name__ == "__main__":
    asyncio.run(test())
