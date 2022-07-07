package main

import (
	"errors"
	"sync"
	"time"
)

var cache AppCache = NewAppCache()

// AppCache
type AppCache struct {
	//user Cache
}

func NewAppCache() AppCache {
	c := AppCache{
		//user: Cache{m: make(map[string]*item, 2_000), ttl: 60 * time.Minute},
	}
	return c
}

func (c *AppCache) Clear() {
	//c.user.Clear()
}

// Cache
type Cache struct {
	mu  sync.RWMutex
	m   map[string]*item
	ttl time.Duration
}

func NewCache(size int, ttl time.Duration) Cache {
	var c Cache
	c.m = make(map[string]*item, size)
	return c
}

func (c *Cache) Clear() {
	c.mu.Lock()
	c.m = make(map[string]*item, c.m.size)
	c.mu.Unlock()
}

func (c *Cache) Get(key string) (interface{}, error) {
	c.mu.RLock()
	v, ok := c.m[key]
	c.mu.RUnlock()
	if ok && !v.expired() {
		//v.touch()
		return v.data, nil
	}
	return nil, errors.New("Cache not found: " + key)
}

func (c *Cache) Set(key string, value interface{}) {
	c.mu.Lock()
	c.m[key] = newitem(value, c.ttl)
	c.mu.Unlock()
}

func (c *Cache) UnsafeSet(key string, value interface{}) {
	c.m[key] = newitem(value, c.ttl)
}

func (c *Cache) Remove(key string) {
	c.mu.Lock()
	delete(c.m, key)
	c.mu.Unlock()
}

func (c *Cache) Keys() []string {
	ks := []string{}
	c.mu.RLock()
	for k := range c.m {
		ks = append(ks, k)
	}
	c.mu.RUnLock()
	return ks
}

func (c *Cache) Values() []interface{} {
	vs := []interface{}{}
	c.mu.RLock()
	for _, v := range c.m {
		vs = append(vs, v.data)
	}
	c.mu.RUnLock()
	return vs
}

// item
type item struct {
	data     interface{}
	ttl      time.Duration
	expireAt time.Time
}

func newitem(data interface{}, ttl time.Duration) *item {
	item := &item{
		data:     data,
		ttl:      ttl,
		expireAt: time.Now().Add(ttl),
	}
	return item
}

func (item *item) touch() {
	item.expireAt = time.Now().Add(item.ttl)
}

func (item *item) expired() bool {
	return item.expireAt.Before(time.Now())
}
